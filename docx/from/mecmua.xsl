<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:prop="http://schemas.openxmlformats.org/officeDocument/2006/custom-properties"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
    xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes"
    xmlns:csp="http://schemas.openxmlformats.org/officeDocument/2006/custom-properties"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:mec="http://mecmua.priv"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="2.0">
    <xsl:import href="docxtotei.xsl"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 30, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b>Omar Siam</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="firstFolioOffset" as="xs:decimal" select="5"/>
    
    <xsl:variable name="folioDescStyle">folio</xsl:variable>
    <xsl:variable name="folioCommentaries">mecmua_Kommentare_zur_Handschrift</xsl:variable>
    
    <xsl:variable name="nameStyle" as="xs:string">Name</xsl:variable>
    <xsl:variable name="placeStyle" as="xs:string">Orte</xsl:variable>
    
    <xsl:variable name="plantStyle" as="xs:string">Pflanzen</xsl:variable>
    <xsl:variable name="plantNameType" as="xs:string">plant</xsl:variable>
    <xsl:variable name="auxSubstStyle" as="xs:string">Zusatzstoffe</xsl:variable>
    <xsl:variable name="auxSubstNameType" as="xs:string">auxSubst</xsl:variable>
    <xsl:variable name="astronomyStyle" as="xs:string">Astronomie</xsl:variable>
    <xsl:variable name="astronomyNameType" as="xs:string">astrEnt</xsl:variable>
    <xsl:variable name="textGenreStyle" as="xs:string">Textgattungen</xsl:variable>
    <xsl:variable name="textGenreNameType" as="xs:string">textGenre</xsl:variable>
    <xsl:variable name="illnessesStyle" as="xs:string">Krankheiten</xsl:variable>
    <xsl:variable name="illnessesNameType" as="xs:string">illness</xsl:variable>
    
    <xsl:variable name="otherStyles" select="($plantStyle, $auxSubstStyle, $astronomyStyle, $textGenreStyle, $illnessesStyle)"/>
    <xsl:variable name="otherNameTypes" select="($plantNameType, $auxSubstNameType, $astronomyNameType, $textGenreNameType, $illnessesNameType)"/>
    
    <xsl:variable name="codId" select="replace(string-join((//w:p//w:pStyle[@w:val=('folio', 'mecmuaKommentarezurHandschrift')])[1]/../..//w:t, ''), '[ .]', '')"></xsl:variable>
    <xsl:variable name="remarkRegExp">(.*)remark:(.*)</xsl:variable>
    <xsl:variable name="remarkMremains">1</xsl:variable>
    <xsl:variable name="remarkM">2</xsl:variable>
    
    <xsl:variable name="nameRegExp" as="xs:string">(aka:(.*))?profession:(.*)died:(.*)reign:(.*)</xsl:variable>
    <!-- 1: aka: ... -->
    <xsl:variable name="nameMaka">2</xsl:variable>
    <xsl:variable name="nameMprof">3</xsl:variable>
    <xsl:variable name="nameMdied">4</xsl:variable>
    <xsl:variable name="nameMreign">5</xsl:variable>

    <xsl:variable name="placeRegExp">(aka:(.*))?type:(.*)where today:(.*)today’s name:(.*)</xsl:variable>
    <!-- 1: aka: ... -->
    <xsl:variable name="placeMaka">2</xsl:variable>
    <xsl:variable name="placeMtype">3</xsl:variable>
    <xsl:variable name="placeMwToday">4</xsl:variable>
    <xsl:variable name="placeMtodayN">5</xsl:variable>
    
    <xsl:variable name="otherRegExp">(aka:(.*))?Latin:(.*)English:(.*)|(aka:(.*))?English:(.*)</xsl:variable>
    <!-- 1: aka: ... -->
    <xsl:variable name="otherMaka">2</xsl:variable>
    <xsl:variable name="otherMakaAlt">6</xsl:variable>
    <xsl:variable name="otherMlat">3</xsl:variable>
    <xsl:variable name="otherMeng">4</xsl:variable>
    <xsl:variable name="otherMengAlt">7</xsl:variable>     

    <xd:doc>
        <xd:desc>No break hyphens actually aren't characters but tags. Convert them to Unicode characters in pass0.
         Doing this in pass1 is to late for this stylesheet.
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:noBreakHyphen" mode="pass0"><w:t>&#x2011;</w:t></xsl:template>

    <xd:doc>
        <xd:desc>Need to join all adjacent text runs with the same character style.
        <xd:p>Note: this is designed so it eats up emtpty text runs including such containing only xreference markers and page breaks.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:p" mode="pass0">
        <w:p>
        <xsl:for-each-group select="* except w:proofErr" group-adjacent="concat('x', ./w:rPr/w:rStyle/@w:val)">
            <xsl:choose>
                <xsl:when test="current-grouping-key() = 'x' or count(current-group() intersect //w:r) &lt; 2">
                    <xsl:for-each select="current-group()">
                        <xsl:if test="empty(current-group() intersect //w:r) or not(empty(current-group()//w:t)) or (string-join(current-group()//w:t, '') ne '')">                            
                        <xsl:copy>
                            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" mode="pass0"/>
                        </xsl:copy>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="current-group() except (//w:r)">
                        <xsl:copy>
                            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" mode="pass0"/>
                        </xsl:copy>
                    </xsl:for-each>
                    <xsl:if test="empty(current-group() intersect //w:r) or not(empty(current-group()//w:t)) or (string-join(current-group()//w:t, '') ne '')">                            
                         <w:r>
                            <xsl:apply-templates select="current-group()[1]/w:rPr" mode="pass0"/>
                            <xsl:apply-templates select="current-group()//w:t|current-group()//w:noBreakHyphen" mode="pass0"/>
                        </w:r>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
        </w:p>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Remove footnote references</xd:desc>
    </xd:doc>
    <xsl:template match="w:footnoteReference"/>
    <xd:doc>
        <xd:desc>Remove endnote references</xd:desc>
    </xd:doc>
    <xsl:template match="w:endnoteReference"/>
    
    <xsl:param name="pass0-from-disk" as="xs:boolean" select="false()"/>
    <xd:doc>
        <xd:desc>Access to $pass0 is needed globally so duplicate this here.</xd:desc>
    </xd:doc>
    <xsl:variable name="pass0">
        <xsl:choose>
            <xsl:when test="$pass0-from-disk">
                <xsl:sequence select="/"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="/" mode="pass0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xd:doc>
        <xd:desc>teiHeader using the metadata agreed upon in the project, fetched from the docx metadata</xd:desc>
    </xd:doc>
    <xsl:template name="create-tei-header">
        <xsl:variable name="docPropsCustom" select="doc(concat($wordDirectory,'/docProps/custom.xml'))"/>
        <xsl:variable name="editionDate" select="$docPropsCustom/csp:Properties/csp:property[@name = 'Edition-date']"/>
        <xsl:variable name="lastModified" select="substring-before($docProps/cp:coreProperties/dcterms:modified,'T')"/>
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <title><xsl:value-of select="$docProps/cp:coreProperties/dc:title"/></title>
                    <author><xsl:value-of select="$docProps/cp:coreProperties/dc:creator"/></author>
                    <respStmt>
                        <resp xml:lang="en">encoded by</resp>
                        <resp xml:lang="de">bearbeitet von</resp>
                        <xsl:for-each select="tokenize($docPropsCustom/csp:Properties/csp:property[@name = 'Encodedby'], ';')">
                                <name><xsl:value-of select="normalize-space(.)"/></name>
                        </xsl:for-each>
                    </respStmt>
                </titleStmt>
                <editionStmt>
                    <edition><note>Fully digitized Edition <xsl:value-of select="$editionDate"></xsl:value-of>. Preliminary version as of <xsl:value-of select="$lastModified"/>.
This is a work in progress. If you find any new or alternative readings or have any suggestions or comments please get in contact with us. mecmua.orientalistik@univie.ac.at</note>
                    </edition>
                    <xsl:for-each select="tokenize($docPropsCustom/csp:Properties/csp:property[@name = 'Finanzierung'], ';')">                        
                       <funder><xsl:value-of select="normalize-space(.)"/></funder>
                    </xsl:for-each>                    
                </editionStmt>
                <extent>
                    <measure type="images"><xsl:value-of select="$docPropsCustom/csp:Properties/csp:property[@name = 'Bilder']"/> facsimile</measure>
                </extent>
                <publicationStmt>
                    <publisher><xsl:value-of select="$docPropsCustom/csp:Properties/csp:property[@name = 'Verleger']"/></publisher>
                    <address><addrLine>Sonnenfelsgasse 19, 1010 Wien, Austria</addrLine></address>
                    <pubPlace>Vienna</pubPlace>
                    <date>
                        <xsl:attribute name="when"><xsl:value-of select="year-from-date(current-date())"/></xsl:attribute>
                        <xsl:value-of select="year-from-date(current-date())"/>
                    </date>
                    <availability status="restricted">
                        <licence></licence>
                    </availability>
                    <idno type="cr-xq">mecmua:<xsl:value-of select="$codId"/></idno>
                </publicationStmt>
                <notesStmt>
                    <note><xsl:value-of select="$docProps/cp:coreProperties/dc:description"/></note>
                </notesStmt>
                <sourceDesc>
                    <bibl type="short"><xsl:value-of select="$docProps/cp:coreProperties/dc:title"/></bibl>
                    <biblStruct>
                        <monogr>
                            <title><xsl:value-of select="$docProps/cp:coreProperties/dc:title"/></title>
                            <author>
                                <name><xsl:value-of select="$docProps/cp:coreProperties/dc:creator"/></name>
                            </author>
                            <imprint>
                                <pubPlace>Ottoman Empire</pubPlace>
                                <publisher>Unknown</publisher>
                                <date>16th Century</date>
                            </imprint>
                            <extent>
                                <num n="pages"><xsl:value-of select="$docPropsCustom/csp:Properties/csp:property[@name = 'extent-pages']"/></num>
                            </extent>
                        </monogr>
                    </biblStruct>
                    <msDesc>
                        <msIdentifier>
                            <settlement><xsl:value-of select="$docPropsCustom/csp:Properties/csp:property[@name = 'msDesc-settlement']"/></settlement>
                            <institution><xsl:value-of select="$docPropsCustom/csp:Properties/csp:property[@name = 'msDesc-institution']"/></institution>
                            <repository><xsl:value-of select="$docPropsCustom/csp:Properties/csp:property[@name = 'msDesc-institution']"/></repository>
                            <idno type="signatory"><xsl:value-of select="$docPropsCustom/csp:Properties/csp:property[@name = 'msDesc-signatory']"/></idno>
                        </msIdentifier>
                    </msDesc>
                </sourceDesc>
            </fileDesc>
            <encodingDesc>
                <projectDesc>
                    <p>Early Modern Ottoman Culture of Learning: Popular Learning between Poetic Ambitions and Pragmatic Concerns</p>
                    <p>In our project we intend to explore some aspects of the Early Modern Ottoman culture of learning, in particular those areas of learning used and cultivated outside the official Ottoman institutions of learning, the medreses.</p>
                    <p>Our main sources for this investigation will be the encyclopaedia Netaic ül-fünun of the 16th century scholar and poet Nevi and a number of mecmuas preserved in the Österreichische Nationalbibliothek and the Haus-, Hof- und Staatsarchiv in Vienna.</p>
                    <p>Our project has two main aims, one basically related to cultural history, the other to pragmatic philological issues:</p>
                    <p>As for cultural history we intend to explore the early modern culture of
                        what can be called the “general” or “popular learning” of educated Ottomans
                        with regard to its own historical context and cultural concepts. The Netaic
                        and the mecmuas will be investigated with regard to their sources, and the
                        backgrounds of their authors and compilers, and of their readers and users.
                        The question of the “popularization” of learning will be raised in
                        particular with regard to the way in which the authors of these works made
                        use of their sources, how the learning was presented, and how the works were
                        used. We will pay special attention to the role of poetry in the Ottoman
                        culture of learning and the way it was applied in the Netaic and the
                        mecmuas.</p>
                    <p>The philological objectives of the project include the compilation of a
                        full critical edition and translation of the Netaic and an edition and
                        translation of selected parts of the mecmuas. The circumstances of the
                        Netaic’s transmission is particularly interesting, and in the course of this
                        project we will explore possible solutions to the problem of editing a text
                        that is today available in a great number of manuscripts (around 60), some
                        of which differ considerably from each other – a situation not unusual for
                        popular Ottoman works.</p>
                    <p>Also, we intend to create an open access database containing the verses,
                        themes, motives, and authors and titles of the various books cited or
                        mentioned in the Netaic and themecmuas. The editions, translations, and the
                        database will provide a solid foundation for further scholarship on Ottoman
                        cultural and literary history.</p>              
                </projectDesc>
                <editorialDecl>
                    <ab>The electronic edition was prepared as OfficeOpenXML (as produced by Microsoft Word 2007) text documents and then converted using XSL 2.0 to documents conforming to the TEI P5 Guildlines.</ab>
                    <ab>Misspellings are indicated by [!], illegible words by [...] and problematic readings by [?]. // indeicates beginnings of new lines.</ab>
                    <normalization>
                        <ab>The orthography of the original is maintained.</ab>
                        <ab>Trancription systems: For Ottoman Turkish the standard transcription-system of the İslam Ansiklopedisi is used (except q instead  ḳ and ė instead i), for Arabic and Persian the transcription-system of the DMG (Deutsche Morgenländische Gesellschaft).</ab>
                    </normalization>
                    <interpretation>
                        <ab>persons, places, plants, illnesses, astronomic/astrologic entities, texts and genres, substances</ab>
                    </interpretation>            
                </editorialDecl>
                <xsl:call-template name="generateAppInfo"/>
            </encodingDesc>
            <profileDesc>
                <langUsage>
                    <xsl:for-each select="tokenize($docPropsCustom/csp:Properties/csp:property[@name = 'Sprache'], ',')">
                        <xsl:variable name="langName" select="normalize-space(.)"/>
                        <xsl:variable name="langSc">
                            <xsl:choose>
                                <xsl:when test="$langName='German'">deu</xsl:when>
                                <xsl:when test="$langName='English'">eng</xsl:when>
                                <xsl:when test="$langName='Ottoman'">ota</xsl:when>
                                <xsl:when test="$langName='Arabic'">ara</xsl:when>
                                <xsl:when test="$langName='Persian'">fas</xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <language ident="{$langSc}"><xsl:value-of select="$langName"/></language>
                    </xsl:for-each>                   
                </langUsage>
                <textClass>
                    <keywords>
                        <list>
                            <xsl:for-each select="tokenize($docProps/cp:coreProperties/cp:keywords, ';')">
                                <item><xsl:value-of select="normalize-space(.)"/></item>
                            </xsl:for-each>                       
                        </list>
                    </keywords>
                </textClass>
            </profileDesc>
            <revisionDesc>
                <change when="{substring-before(tei:whatsTheDate(),'T')}" who="{$docPropsCustom/csp:Properties/csp:property[@name = 'Encodedby']}"/>
            </revisionDesc>
        </teiHeader>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Empty notes would be zapped otherwise</xd:desc>
    </xd:doc>
    <xsl:template match="tei:note[not(*) and not(text()) and parent::tei:notesStmt]" mode="pass2">
        <!-- at least an empty note is mandatory -->
        <note/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Handle character styles that have a special meaning in the mecmua project and ignore some styles that we defined to be suppressed.
            <xd:p>Note: uses a cusotmization in textruns.xsl.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="onUnknownStyle">
        <xsl:param name="style"/>
        <xsl:choose>
            <xsl:when test="$style='Kommentarzeichen'"/> <!-- supress -->
            <xsl:when test="$style='annotation reference'"/> <!-- supress -->
            <xsl:when test="$style='footnote reference'"/><!-- suppress -->
            <xsl:when test="$style='Funotenzeichen'"/><!-- suppress -->
            <xsl:when test="$style=($nameStyle, $placeStyle, $otherStyles)">
                <xsl:choose>
                    <xsl:when test="(preceding-sibling::w:commentRangeStart[1])/@w:id">
                        <xsl:call-template name="semanticStyle">
                            <xsl:with-param name="style" select="$style"/>
                        </xsl:call-template>        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="semanticStyleInfoMissing">
                            <xsl:with-param name="style" select="$style"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="onUnknownStyle-base">
                    <xsl:with-param name="style" select="$style"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>The template generateAppInfo is customized but also adds the whole section describing the named entities taged in the body.</xd:desc>
    </xd:doc>
    <xsl:template name="generateAppInfo">
        <appInfo>
            <application ident="TEI_fromDOCX_for_Mecmua" version="2.15.0mecmua">
                <desc>DOCX to TEI for mecmua, TEI XSL Stylesheets adapted for the project by Omar Siam</desc>
            </application>
            <xsl:if test="doc-available(concat($wordDirectory,'/docProps/custom.xml'))">
                <xsl:for-each select="document(concat($wordDirectory,'/docProps/custom.xml'))/prop:Properties">
                    <xsl:for-each select="prop:property">
                        <xsl:choose>
                            <xsl:when test="@name='TEI_fromDOCX'"/>
                            <xsl:when test="contains(@name,'TEI')">
                                <application ident="{@name}" version="{.}">
                                    <label>
                                        <xsl:value-of select="@name"/>
                                    </label>
                                </application>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                    <xsl:if test="prop:property[@name='WordTemplateURI']">
                        <application ident="WordTemplate" version="{prop:property[@name='WordTemplate']}">
                            <label>Word template file</label>
                            <ptr target="{prop:property[@name='WordTemplateURI']}"/>
                        </application>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </appInfo>
<!--        <xsl:sequence select="$tagsDecl"/>-->
        <xsl:call-template name="_generateTagsDecl"/>
<!--        <xsl:result-document href="tagsDecl.xml">
            <xsl:call-template name="_generateTagsDecl"/>
        </xsl:result-document>-->
    </xsl:template>
    
    <xd:doc>
        <xd:desc>This uses a customization in functions.xsl to mark the sections in mecmua documents that is the folios.</xd:desc>
    </xd:doc>
    <xsl:function name="tei:custom-is-firstlevel-heading" as="xs:boolean">
        <xsl:param name="p" as="node()"/>
        <xsl:param name="s" as="xs:string*"/>    
        <xsl:choose>
            <xsl:when test="($s eq $folioDescStyle) and
                matches(string-join($p//w:t, ''), '\d+[vr]:')">true</xsl:when>
            <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Within the folios there are subsections that describe parts of the text that were added on top of the original writing.</xd:desc>
    </xd:doc>
    <xsl:function name="tei:custom-is-heading" as="xs:boolean">
        <xsl:param name="p" as="node()"/>
        <xsl:param name="s" as="xs:string*"/>
        <xsl:value-of select="($s ne '') and ($s eq $folioDescStyle)"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>For the mecmua project the next level headers are in most cases descriptions of other writings around or on top of the original text.</xd:desc>
    </xd:doc>
    <xsl:function name="tei:get-nextlevel-header" as="xs:string">
        <xsl:param name="current-header"/>
        <xsl:choose>
            <xsl:when test="$current-header eq $folioDescStyle">
                <xsl:value-of select="$folioDescStyle"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="translate($current-header,'12345678','23456789')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Superseeds the default as page breaks of the described documents are not identical to the docx page breaks but denoted by the
        folio descriptions.</xd:desc>
    </xd:doc>
    <xsl:template name="generate-section-heading">
        <xsl:param name="Style"/>
        <xsl:variable name="heading" select="string-join(.//w:t/text(), '')"/>
        <xsl:choose>
            <xsl:when test="matches($heading, '^\s*\d+[vr]:')">
                <xsl:variable name="folDesc" select="replace($heading, '^ *(\d+[vr]).*', '$1')"/>
                <xsl:variable name="rv" select="replace($folDesc, '\d+', '')"/>
                <xsl:variable name="vplus1" select="if ($rv eq 'v') then 1 else 0" as="xs:decimal"/>
                <xsl:variable name="folNum" select="xs:decimal(replace($folDesc, '[rv]', ''))" as="xs:decimal"/>
                <pb n="{concat($codId, ' ', format-number($folNum, '000'), $rv)}" facs="{concat($codId, '/', format-number((($folNum - 1) * 2) + $firstFolioOffset + $vplus1, '00000000'))}"/>
                <p rend="{$folioDescStyle}">
                    <hi rend="{$folioCommentaries}">
                    <xsl:value-of select="concat($codId, ': ', $folDesc)"/>
                    </hi>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <p>
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Customized group by section as we don't need more sepcific div elements.
        </xd:desc>
    </xd:doc>
    <xsl:template name="group-by-section">
        <xsl:variable name="Style" select="w:pPr/w:pStyle/@w:val"/>
        <xsl:variable name="NextHeader" select="tei:get-nextlevel-header($Style)"/>
        <xsl:variable name="heading" select="string-join(.//w:t/text(), '')"/>
        <div>
            <xsl:if test="matches($heading, '\d+[vr]:')">
                <xsl:attribute name="xml:id" select="concat($codId, generate-id(.))"/>
                <xsl:attribute name="type">page</xsl:attribute>
            </xsl:if>
            <!-- generate the head -->
            <xsl:call-template name="generate-section-heading">
                <xsl:with-param name="Style" select="$Style"/>
            </xsl:call-template>
            
            <!-- Process sub-sections -->
            <xsl:for-each-group select="current-group() except ."
                group-starting-with="w:p[w:pPr/w:pStyle/@w:val=$NextHeader]">
                <xsl:choose>
                    <xsl:when test="tei:is-heading(.)">
                        <xsl:call-template name="group-by-section"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="." mode="inSectionGroup"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </div>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Comments have to be preprocessed the same way the main document is preprocessd. E. g. to join text runs that Word generated
        for some reason.</xd:desc>
    </xd:doc>
    <xsl:variable name="comments">
        <xsl:apply-templates mode="pass0" select="document(concat($wordDirectory,'/word/comments.xml'))"/>
    </xsl:variable>
    
    <xsl:variable name="tagsDecl">
        <xsl:call-template name="_generateTagsDecl"/>
    </xsl:variable>
    
    <xsl:template name="tagsDeclName">
        <xsl:param name="remark" as="xs:string" select="''"/>
        <xsl:param name="annotationText" as="xs:string"/>
        <xsl:param name="wordInText" as="xs:string"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="generated-id" as="xs:string"/>
        <xsl:element name="person">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="$generated-id"/>
            </xsl:attribute>
            <xsl:analyze-string select="$annotationText"
                regex="{$nameRegExp}">
                <xsl:matching-substring>
                    <persName xml:lang="ota-Latn-t">
                        <xsl:value-of select="$wordInText"/>
                        <xsl:for-each select="tokenize(regex-group($nameMaka), '[,;]')">
                            <addName xml:lang="ota-Latn-t">                                                    
                                <xsl:value-of
                                    select="normalize-space(.)"/>
                            </addName>
                        </xsl:for-each>
                    </persName>
                    <occupation>
                        <xsl:value-of
                            select="normalize-space(regex-group($nameMprof))"/>
                    </occupation>
                    <death>
                        <xsl:value-of
                            select="normalize-space(regex-group($nameMdied))"/>
                    </death>
                    <xsl:if test="normalize-space(regex-group($nameMreign)) != ''">
                        <xsl:variable name="reign" select="normalize-space(regex-group($nameMreign))"/>
                        <xsl:analyze-string select="$reign" regex="(.*)[-‑](.*)">
                            <xsl:matching-substring>
                                <floruit>                                                    
                                    <xsl:attribute name="from-custom"
                                        select="normalize-space(regex-group(1))"/>
                                    <xsl:attribute name="to-custom"
                                        select="normalize-space(regex-group(2))"/>
                                </floruit>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <floruit>                                                    
                                    <xsl:attribute name="from-custom"
                                        select="$reign"/>
                                </floruit>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:if>
                    <xsl:if test="$remark ne ''">
                        <note>
                            <xsl:value-of select="$remark"/>
                        </note>
                    </xsl:if>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <persName>
                        <xsl:value-of select="$wordInText"/>
                    </persName>
                    <xsl:choose>
                        <xsl:when test="$annotationText = ' '">
                            <note>This name is not annotated! No annotation found.</note>
                        </xsl:when>
                        <xsl:otherwise>
                            <note>
                                <xsl:value-of select="concat('This name is not annotated correctly! Details: &quot;', $annotationText, '&quot;')"/>
                            </note>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="tagsDeclPlace">
        <xsl:param name="remark" as="xs:string" select="''"/>
        <xsl:param name="annotationText" as="xs:string"/>
        <xsl:param name="wordInText" as="xs:string"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="generated-id" as="xs:string"/>
        <xsl:variable name="contents">
            <xsl:analyze-string select="$annotationText" regex="{$placeRegExp}">
                <xsl:matching-substring>
                    <place>
                        <xsl:attribute name="type">
                            <xsl:value-of
                                select="if (normalize-space(regex-group($placeMtype)) ne '') then replace(normalize-space(regex-group($placeMtype)), '[ ;,:]', '_') else 'unknown'"
                            />
                        </xsl:attribute>
                        <placeName xml:lang="ota-Latn-t">
                            <xsl:value-of select="$wordInText"/>
                            <xsl:for-each select="tokenize(regex-group($placeMaka), '[,;]')">
                                <addName xml:lang="ota-Latn-t">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </addName>
                            </xsl:for-each>
                            <addName xml:lang="en-UK">
                                <xsl:value-of select="normalize-space(regex-group($placeMtodayN))"/>
                            </addName>
                        </placeName>
                        <location>
                            <country>
                                <xsl:value-of select="normalize-space(regex-group($placeMwToday))"/>
                            </country>
                        </location>
                        <xsl:if test="$remark">
                            <note>
                                <xsl:value-of select="$remark"/>
                            </note>
                        </xsl:if>
                    </place>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <place>
                        <placeName>
                            <xsl:value-of select="$wordInText"/>
                        </placeName>
                        <xsl:choose>
                            <xsl:when test="$annotationText = ' '">
                                <note>This name is not annotated! No annotation found.</note>
                            </xsl:when>
                            <xsl:otherwise>
                                <note>
                                    <xsl:value-of
                                        select="concat('This name is not annotated correctly! Details: &quot;', $annotationText, '&quot;')"
                                    />
                                </note>
                            </xsl:otherwise>
                        </xsl:choose>
                    </place>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <place xml:id="{$generated-id}">
            <xsl:sequence select="$contents/tei:place/@*, $contents/tei:place/node()"/>
        </place>
    </xsl:template>

    <xsl:template name="tagsDeclOther">
        <xsl:param name="remark" as="xs:string" select="''"/>
        <xsl:param name="annotationText" as="xs:string"/>
        <xsl:param name="wordInText" as="xs:string"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="generated-id" as="xs:string"/>
        <xsl:element name="nym">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="$generated-id"/>
            </xsl:attribute>
            <xsl:attribute name="type">
                <xsl:value-of select="$type"/>
            </xsl:attribute>
<!--            <orth xml:lang="ota-Latn-t">
                <xsl:value-of select="$wordInText"/>
            </orth>-->
<!--            <xsl:if test="lower-case($wordInText) ne $wordInText">-->
                <orth xml:lang="ota-Latn-t">
                    <xsl:value-of select="concat(lower-case(substring($wordInText, 1, 1)), substring($wordInText, 2))"/>    
                </orth>
<!--            </xsl:if>-->
            <xsl:analyze-string select="$annotationText" regex="{$otherRegExp}">
                <xsl:matching-substring>
                    <xsl:for-each select="tokenize(if (regex-group($otherMaka) eq '') then regex-group($otherMakaAlt) else regex-group($otherMaka), '[,;]')">
                        <orth xml:lang="ota-Latn-t">                                                    
                            <xsl:value-of
                                select="normalize-space(.)"/>
                        </orth>
                    </xsl:for-each>
                    <sense xml:lang="la">
                        <xsl:value-of select="normalize-space(regex-group($otherMlat))"/>
                    </sense>
                    <sense xml:lang="en-UK">
                        <xsl:value-of select="normalize-space(if (regex-group($otherMeng) eq '') then regex-group($otherMengAlt) else regex-group($otherMeng))"/>
                    </sense>
                    <xsl:if test="$remark ne ''">
                    <ab>
                        <note>
                            <xsl:value-of select="$remark"/>
                        </note>
                    </ab>
                    </xsl:if>
                </xsl:matching-substring>                                            
                <xsl:non-matching-substring>
                    <ab>
                        <xsl:choose>
                            <xsl:when test="$annotationText = ' '">
                                <note>This name is not annotated! No annotation found.</note>
                            </xsl:when>
                            <xsl:otherwise>
                                <note>
                                    <xsl:value-of
                                        select="concat('This name is not annotated correctly! Details: &quot;', $annotationText, '&quot;')"
                                    />
                                </note>
                            </xsl:otherwise>
                        </xsl:choose>
                    </ab>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:element>       
    </xsl:template>

    <xd:do>
        <xd:desc>Aux function to find the relative position of a particular node in within a sequence.</xd:desc>
    </xd:do>
    <xsl:function name="mec:relative-position" as="xs:integer">
        <xsl:param name="aSequence" as="node()+"/>
        <xsl:param name="aNodeWithinTheSequence" as="node()?"/>
        <xsl:choose>
            <xsl:when test="exists($aNodeWithinTheSequence)">
                <xsl:variable name="aNodeId" select="generate-id($aNodeWithinTheSequence)"/>
                <xsl:for-each select="$aSequence">
                    <xsl:if test="generate-id(.) eq $aNodeId">
                        <xsl:value-of select="position()"/> 
                    </xsl:if>
                </xsl:for-each>                
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Given a context (most probably .) and the comments id this returns the words in the text that make up the named entity.</xd:desc>
    </xd:doc>
    <xsl:function name="mec:words-in-text-runs" as="xs:string">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="commentId" as="xs:string?"/>
        <xsl:variable name="possibleWordInTextRuns" select="($context | $context/following-sibling::w:r)"/>
        <xsl:variable name="lastRunElement" select="$context/following-sibling::w:commentRangeEnd[@w:id = $commentId]/preceding-sibling::w:r[1]"/>
        <xsl:variable name="lastRunPosition" select="mec:relative-position($possibleWordInTextRuns, $lastRunElement)"/>
        <xsl:value-of select="if (exists($commentId)) then string-join($possibleWordInTextRuns[position() = (1 to $lastRunPosition)]/w:t, '')
                                                      else string-join($context/w:t, '')"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>Given a context (most probably .) this returns the words in the id of the assiciated annotation if any.</xd:desc>
    </xd:doc>
    <xsl:function name="mec:getAnnotationId" as="xs:string?">
        <xsl:param name="context" as="node()"/>        
        <xsl:variable name="numPrecedingSiblings"
            select="count($context/preceding-sibling::*)"/>
        <xsl:variable name="prevCommentEnd"
            select="$context/preceding-sibling::w:commentRangeEnd[1]" as="node()?"/>
        <xsl:variable name="numPSPrevEnd"
            select="count($prevCommentEnd/preceding-sibling::*)"/>
        <xsl:variable name="assocCommentStart"
            select="$context/preceding-sibling::w:commentRangeStart[1]" as="node()?"/>
        <xsl:variable name="numPSAssocStart"
            select="count($assocCommentStart/preceding-sibling::*)"/>
        <xsl:variable name="nextCommentStart"
            select="$context/following-sibling::w:commentRangeStart[1]" as="node()?"/>
        <xsl:variable name="numPSNextStart"
            select="count($nextCommentStart/preceding-sibling::*)"/>           
        <xsl:variable name="assocCommentEnd"
            select="$context/following-sibling::w:commentRangeEnd[1]" as="node()?"/>
        <xsl:variable name="numPSAsoocEnd"
            select="count($assocCommentEnd/preceding-sibling::*)"/>
        <xsl:value-of
            select="if (empty($assocCommentStart) or ($numPSPrevEnd > $numPSAssocStart)) then 
            if ($numPSNextStart > $numPSAsoocEnd) then $assocCommentEnd/@w:id else ()
            else $assocCommentStart/@w:id"/>        
    </xsl:function>
    
    <xsl:template name="generatePersonNameXML">
        <xsl:variable name="thisId"
            select="mec:getAnnotationId(.)"/>
        <xsl:variable name="annotationText"
            select="if (exists($thisId)) then normalize-space(string-join($comments/w:comments/w:comment[@w:id = $thisId]//w:t, '')) else ' '"/>
        <xsl:variable name="wordInText" select="mec:words-in-text-runs(., $thisId)" as="xs:string"/>
        <!-- TODO: replace with lookup -->
        <xsl:variable name="type" select="./w:rPr/w:rStyle/@w:val"
            as="xs:string?"/>
        <xsl:variable name="generated-id" select="generate-id()"/>
        <xsl:analyze-string select="$annotationText" regex="{$remarkRegExp}">
            <xsl:matching-substring>
                <xsl:call-template name="tagsDeclName">
                    <xsl:with-param name="remark"><xsl:value-of select="normalize-space(regex-group($remarkM))"/></xsl:with-param>
                    <xsl:with-param name="annotationText"><xsl:value-of select="normalize-space(regex-group($remarkMremains))"/></xsl:with-param>
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="wordInText" select="$wordInText"/>
                    <xsl:with-param name="generated-id" select="$generated-id"/>
                </xsl:call-template>                                           
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:call-template name="tagsDeclName">
                    <xsl:with-param name="annotationText"><xsl:value-of select="$annotationText"/></xsl:with-param>
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="wordInText" select="$wordInText"/>
                    <xsl:with-param name="generated-id" select="$generated-id"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="generatePlaceNameXML">
        <xsl:variable name="thisId" as="xs:string?" select="mec:getAnnotationId(.)"/>
        <xsl:variable name="annotationText"
            select="if (exists($thisId)) then normalize-space(string-join($comments/w:comments/w:comment[@w:id = $thisId]//w:t, '')) else ' '"/>
        <xsl:variable name="wordInText" select="mec:words-in-text-runs(., $thisId)" as="xs:string"/>
        <!-- TODO: replace with lookup -->
        <xsl:variable name="type" select="./w:rPr/w:rStyle/@w:val"
            as="xs:string?"/>
        <xsl:variable name="generated-id" select="generate-id()"/>
        <xsl:analyze-string select="$annotationText" regex="{$remarkRegExp}">
            <xsl:matching-substring>
                <xsl:call-template name="tagsDeclPlace">
                    <xsl:with-param name="remark"><xsl:value-of select="normalize-space(regex-group($remarkM))"/></xsl:with-param>
                    <xsl:with-param name="annotationText"><xsl:value-of select="normalize-space(regex-group($remarkMremains))"/></xsl:with-param>
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="wordInText" select="$wordInText"/>
                    <xsl:with-param name="generated-id" select="$generated-id"/>
                </xsl:call-template>                                           
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:call-template name="tagsDeclPlace">
                    <xsl:with-param name="annotationText"><xsl:value-of select="$annotationText"/></xsl:with-param>
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="wordInText" select="$wordInText"/>
                    <xsl:with-param name="generated-id" select="$generated-id"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>       
    </xsl:template>
    
    <xsl:template name="generateOtherNameXML">
        <xsl:variable name="thisId"
            select="mec:getAnnotationId(.)"/>
        <xsl:variable name="annotationText"
            select="if (exists($thisId)) then normalize-space(string-join($comments/w:comments/w:comment[@w:id = $thisId]//w:t, '')) else ' '"/>
        <xsl:variable name="wordInText" select="mec:words-in-text-runs(., $thisId)" as="xs:string"/>
        <xsl:variable name="type" select="mec:mapStyle(./w:rPr/w:rStyle/@w:val)"
            as="xs:string?"/>
        <xsl:variable name="generated-id" select="generate-id()"/>
        <xsl:analyze-string select="$annotationText" regex="{$remarkRegExp}">
            <xsl:matching-substring>
                <xsl:call-template name="tagsDeclOther">
                    <xsl:with-param name="remark" select="normalize-space(regex-group($remarkM))"/>
                    <xsl:with-param name="annotationText" select="normalize-space(regex-group($remarkMremains))"/>
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="wordInText" select="$wordInText"/>
                    <xsl:with-param name="generated-id" select="$generated-id"/>
                </xsl:call-template>                                           
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:call-template name="tagsDeclOther">
                    <xsl:with-param name="annotationText"><xsl:value-of select="$annotationText"/></xsl:with-param>
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="wordInText" select="$wordInText"/>
                    <xsl:with-param name="generated-id" select="$generated-id"/>
                </xsl:call-template>
            </xsl:non-matching-substring>
        </xsl:analyze-string>        
    </xsl:template>
    
    <!-- Clean up: http://stackoverflow.com/questions/1233702/how-to-call-named-templates-based-on-a-variable -->
    <xsl:template name="_generateTagsDecl">
        <!-- context of caller (=$pass0) -->
        <xsl:variable name="names" select="$pass0//w:r[descendant::w:rStyle/@w:val=$nameStyle]"/>
        <xsl:variable name="places" select="$pass0//w:r[descendant::w:rStyle/@w:val=$placeStyle]"/>
        <xsl:variable name="otherNames"
            select="$pass0//w:r[descendant::w:rStyle/@w:val=$otherStyles]"/>
        <tagsDecl>
            <namespace name="http://www.tei-c.org/ns/1.0">
                <xsl:if test="exists($pass0//w:rStyle[@w:val=$placeStyle])">
                    <tagUsage gi="persName">
                        <listPerson>
                            <xsl:for-each select="$names">
                                <xsl:call-template name="generatePersonNameXML"/>
                            </xsl:for-each>
                        </listPerson>
                    </tagUsage>
                </xsl:if>
                <xsl:if test="exists($pass0//w:rStyle[@w:val=$placeStyle])">
                    <tagUsage gi="placeName">
                        <listPlace>
                            <xsl:for-each select="$places">
                                <xsl:call-template name="generatePlaceNameXML"></xsl:call-template>
                            </xsl:for-each>
                        </listPlace>
                    </tagUsage>
                </xsl:if>
                <xsl:if test="exists($pass0//w:rStyle[@w:val=$otherStyles])">
                    <tagUsage gi="name">
                        <listNym>
                            <xsl:for-each select="$otherNames">
                                <xsl:call-template name="generateOtherNameXML"></xsl:call-template>
                            </xsl:for-each>
                        </listNym>
                    </tagUsage>
                </xsl:if>
            </namespace>
        </tagsDecl>
    </xsl:template>
    
    <xsl:function name="mec:otherInfo" as="node()+">
        <xsl:param name="commentString" as="xs:string"/>
        <xsl:analyze-string select="$commentString" regex="{$otherRegExp}">
                <xsl:matching-substring>
                    <sense xml:lang="la">
                        <xsl:value-of
                            select="normalize-space(regex-group(1))"/>
                    </sense>
                    <xsl:analyze-string select="regex-group(2)" regex="{$remarkRegExp}">
                    <xsl:matching-substring>
                    <sense xml:lang="en-UK">
                        <xsl:value-of
                            select="normalize-space(regex-group(1))"/>
                    </sense>
                    <ab>
                        <note>
                            <xsl:value-of
                                select="normalize-space(regex-group(2))"/>
                        </note>
                    </ab>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <sense xml:lang="en-UK">
                            <xsl:value-of
                                select="normalize-space(.)"/>
                        </sense>
                    </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:matching-substring>                                            
                <xsl:non-matching-substring>
                    <ab>
                        <note> This name is not annotated correctly!
                            <xsl:value-of select="normalize-space(.)"/>
                        </note>
                    </ab>
                </xsl:non-matching-substring>
            </xsl:analyze-string>            
        
    </xsl:function>

    <xd:doc>
        <xd:desc>Remove texts containing n.a. when comparing</xd:desc>
    </xd:doc>
<!--    <xsl:template match="*[contains(text()[1], 'n.a.')]" mode="prepare-comment"/>-->

    <xd:doc>
        <xd:desc>Remove attributes containing n.a. when comparing</xd:desc>
    </xd:doc>    
<!--    <xsl:template match="@*[contains(., 'n.a.')]" mode="prepare-comment"/>-->
    
    <xd:doc>
        <xd:desc>Create a copy for comparing</xd:desc>
    </xd:doc>
    <xsl:template match="*" mode="prepare-comment">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="prepare-comment"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>Create a copy for comparing</xd:desc>
    </xd:doc>
    <xsl:template match="@*" mode="prepare-comment">
        <xsl:copy> . </xsl:copy>
    </xsl:template>
    
    <!--<xsl:variable name="missing_info_marker" select="'info_missing'"/>-->
    <!-- will lead to validation failures becaus it generates ref="" -->
    <xsl:variable name="missing_info_marker" select="''"/>
    
    <xsl:function name="mec:getRefIdPerson" as="xs:string?">
        <xsl:param name="name" as="xs:string+"/>
        <xsl:param name="commentN" as="xs:string"/>
        <xsl:param name="commentXML" as="document-node()?"/>
        <xsl:variable name="lcName" as="xs:string+">
            <xsl:for-each select="$name">
                <xsl:value-of select="concat(lower-case(substring(., 1, 1)), substring(., 2))"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="allPossibleMatchingNamesComment"
            select="($tagsDecl//tei:person[tei:persName/text()[1] = ($lcName, $name)]|$tagsDecl//tei:person[tei:persName/tei:addName = ($lcName, $name)])"/>
        <xsl:variable name="allMatchingNamesComment"
            select="$allPossibleMatchingNamesComment[not(contains(.//tei:note[1], 'not annotated'))]"/>
        <xsl:variable name="firstMatchingNamesId" select="$allMatchingNamesComment[1]/@xml:id"/>
        <xsl:choose>
            <xsl:when test="empty($allMatchingNamesComment)">
                <!-- Error: finds comment for the next unrelated name!! -->
                <!--       select="concat($commentN,'-',($tagsDecl//tei:person[tei:persName/text()[1] = $name]|$tagsDecl//tei:person[tei:persName/tei:addName = $name])[1]/@xml:id)"-->
                <xsl:value-of
                    select="if (empty($allPossibleMatchingNamesComment[1]/@xml:id)) then $missing_info_marker else $allPossibleMatchingNamesComment[1]/@xml:id"
                />
            </xsl:when>
            <xsl:when test="empty($commentXML)">
                <xsl:value-of select="$firstMatchingNamesId"/>
            </xsl:when>
            <xsl:when test="$commentN eq ''">
                <xsl:value-of select="$firstMatchingNamesId"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="preparedCommentXML">
                    <xsl:apply-templates select="$commentXML" mode="prepare-comment"/>
                </xsl:variable>
                <xsl:value-of
                    select="string-join(mec:disambiguate($preparedCommentXML, $allMatchingNamesComment)/@xml:id, 'error: ')"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Disambiguate by checking a comment against candidates.</xd:desc>
    </xd:doc>
    <xsl:function name="mec:disambiguate" as="element()">
        <!-- idea search for best candidate not finished: replace 1 exists((tei:occupation, tei:death, tei:floruit)) -->
        <xsl:param name="comment" as="node()+"/>
        <xsl:param name="candidates" as="element()+"/>
        <xsl:variable name="similarityPoints" as="element()*">
            <xsl:for-each select="$candidates">
                <mec:s>
                    <xsl:sequence select="mec:similarityPoints(., $comment), ()"/>
                </mec:s>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="mec:disambiguate($comment, $candidates, $similarityPoints)"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Disambiguate by checking a comment against candidates. Comparison results are passed on.</xd:desc>
    </xd:doc>
    <xsl:function name="mec:disambiguate" as="element()">
        <!-- idea search for best candidate not finished: replace 1 exists((tei:occupation, tei:death, tei:floruit)) -->
        <xsl:param name="comment" as="node()+"/>
        <xsl:param name="candidates" as="element()+"/>
        <xsl:param name="similarityPoints" as="element()*"/>
        <xsl:choose>
            <xsl:when test="count($candidates) = 1">
                <xsl:sequence select="$candidates"/>
            </xsl:when>
            <xsl:when test="count($similarityPoints[2]/*) &gt; count($similarityPoints[1]/*)">
                <xsl:sequence
                    select="mec:disambiguate($comment, subsequence($candidates, 2), subsequence($similarityPoints, 2))"
                />
            </xsl:when>
            <xsl:when test="count($similarityPoints[1]/*) &gt; count($similarityPoints[2]/*)">
                <xsl:sequence
                    select="mec:disambiguate($comment, remove($candidates, 2), remove($similarityPoints, 2))"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence
                    select="mec:disambiguate($comment, remove($candidates, 2), remove($similarityPoints, 2))"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Compare two generated TEI structures reporting every match using a tag as a point.</xd:desc>
    </xd:doc>
    <xsl:function name="mec:similarityPoints" as="element()*">
        <xsl:param name="candidate" as="node()"/>
        <xsl:param name="comment" as="node()"/>
        <xsl:variable name="ownID" as="xs:string?" select="$comment//tei:person/@xml:id | $comment//tei:place/@xml:id | $comment//tei:nym/@xml:id"/>
        <!-- See if we already have this name tagged but with another name in the running text -->
        <!-- Here all sorts of mix and match may occur within one type. -->
        <xsl:for-each select="$candidate//tei:persName/text()[1] | $candidate//tei:placeName/text()[1] | $candidate//tei:orth/text()[1] | $candidate//tei:addName/text()[1]">
            <xsl:if test=". = ($comment//tei:orth/text()[1] | $comment//tei:addName/text()[1])">
                    <mec:s/>
                </xsl:if>
            </xsl:for-each>
        <xsl:if test="($candidate[@xml:id ne $ownID]//tei:persName/text()[1] | $candidate[@xml:id ne $ownID]//tei:placeName/text()[1]) = ($comment//tei:persName/text()[1] | $comment//tei:placeName/text()[1])">
            <mec:s/>
        </xsl:if>                    
        <!-- Matching specific to persons. -->
        <xsl:if test="$comment//tei:occupation = ($candidate//tei:occupation, '')">
            <mec:s/>
        </xsl:if>
        <xsl:if test="$comment//tei:occupation = ($candidate//tei:occupation)">
            <mec:s/>
        </xsl:if>
        <xsl:if test="$comment//tei:death = ($candidate//tei:death, '')">
            <mec:s/>
        </xsl:if>
        <xsl:if test="$comment//tei:death = ($candidate//tei:death)">
            <mec:s/>
        </xsl:if>
        <xsl:if test="$comment//tei:floruit/@from-custom = ($candidate//tei:floruit/@from-custom, '')">
            <mec:s/>
        </xsl:if>
        <xsl:if test="$comment//tei:floruit/@from-custom = ($candidate//tei:floruit/@from-custom)">
            <mec:s/>
        </xsl:if>
        <xsl:if test="$comment//tei:floruit/@to-custom = ($candidate//tei:floruit/@to-custom, '')">
            <mec:s/>
        </xsl:if>
        <xsl:if test="$comment//tei:floruit/@to-custom = ($candidate//tei:floruit/@to-custom)">
            <mec:s/>
        </xsl:if>
        <!-- Matching specific to places. -->
        <xsl:if test="$comment//tei:country = ($candidate//tei:country, '')">
            <mec:s/>
        </xsl:if>
        <xsl:if test="$comment//tei:country = ($candidate//tei:country)">
            <mec:s/>
        </xsl:if>
        <!-- Matching specific to other things. -->
        <xsl:for-each select="$comment//tei:sense/text()[1]">
            <xsl:if test=". = ($candidate//tei:sense/text()[1], '')">
                <mec:s/>    
            </xsl:if>
            <xsl:if test=". = ($candidate//tei:sense/text()[1])">
                <mec:s/>    
            </xsl:if>        </xsl:for-each>
        <!-- Check of remarks/notes are part of the comment is contained in the candidate. -->
        <xsl:if test="contains($candidate//tei:note, $comment//tei:note)">
            <mec:s/>
        </xsl:if>        
        <xsl:if test="$comment//tei:note = ($candidate//tei:note, '')">
            <mec:s/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="mec:getRefIdPlace" as="xs:string">
        <xsl:param name="name" as="xs:string+"/>
        <xsl:param name="commentN" as="xs:string"/>
        <xsl:param name="commentXML" as="document-node()?"/>
        <xsl:variable name="lcName" as="xs:string+">
            <xsl:for-each select="$name">
                <xsl:value-of select="concat(lower-case(substring(., 1, 1)), substring(., 2))"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="allPossibleMatchingNamesComment" select="($tagsDecl//tei:place[tei:placeName/text()[1] = ($lcName, $name)]|$tagsDecl//tei:place[tei:placeName/tei:addName = ($lcName, $name)])"/>
        <xsl:variable name="allMatchingNamesComment"
            select="$allPossibleMatchingNamesComment[not(contains(.//tei:note, 'not annotated'))]"/>
        <xsl:variable name="firstMatchingNamesId" select="$allMatchingNamesComment[1]/@xml:id"/>
        <xsl:choose>
            <xsl:when test="empty($allMatchingNamesComment)">
                <xsl:value-of select="if (empty($allPossibleMatchingNamesComment[1]/@xml:id)) then $missing_info_marker else $allPossibleMatchingNamesComment[1]/@xml:id"/>                                                        
            </xsl:when>
            <xsl:when test="empty($commentXML)">
                <xsl:value-of select="$firstMatchingNamesId"/>
            </xsl:when>
            <xsl:when test="$commentN eq ''">
                <xsl:value-of select="$firstMatchingNamesId"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="preparedCommentXML">
                    <xsl:apply-templates select="$commentXML" mode="prepare-comment"/>
                </xsl:variable>
                <xsl:value-of
                    select="string-join(mec:disambiguate($preparedCommentXML, $allMatchingNamesComment)/@xml:id, 'error: ')"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="mec:getRefIdOtherNames" as="xs:string">
        <xsl:param name="name" as="xs:string+"/>
        <xsl:param name="commentN" as="xs:string"/>
        <xsl:param name="commentXML" as="document-node()?"/>
        <xsl:variable name="lcName" as="xs:string+">
            <xsl:for-each select="$name">
                <xsl:value-of select="concat(lower-case(substring(., 1, 1)), substring(., 2))"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="allPossibleMatchingNamesComment" select="($tagsDecl//tei:nym[tei:orth[@xml:lang = 'ota-Latn-t']/text() = ($lcName, $name)])"/>
        <xsl:variable name="allMatchingNamesComment"
            select="$allPossibleMatchingNamesComment[not(contains(.//tei:note, 'not annotated'))]"/>
        <xsl:variable name="firstMatchingNamesId" select="$allMatchingNamesComment[1]/@xml:id"/>
        <xsl:choose>
            <xsl:when test="empty($allMatchingNamesComment)">
                <xsl:value-of select="if (empty($allPossibleMatchingNamesComment[1]/@xml:id)) then $missing_info_marker else $allPossibleMatchingNamesComment[1]/@xml:id"/>                                        
            </xsl:when>
            <xsl:when test="empty($commentXML)">
                <xsl:value-of select="$firstMatchingNamesId"/>
            </xsl:when>
            <xsl:when test="$commentN eq ''">
                <xsl:value-of select="$firstMatchingNamesId"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="preparedCommentXML">
                    <xsl:apply-templates select="$commentXML" mode="prepare-comment"/>
                </xsl:variable>
                <xsl:value-of
                    select="string-join(mec:disambiguate($preparedCommentXML, $allMatchingNamesComment)/@xml:id, 'error: ')"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Sometimes one has to override the semantic style's default color.</xd:desc>
    </xd:doc>
    <xsl:template name="semanticStyle">
        <xsl:param name="style"/>
        <xsl:choose>
            <xsl:when test="w:rPr/w:color and
                not(w:rPr/w:color/@w:val='000000' or w:rPr/w:color/@w:val='auto')">
                <hi>
                    <xsl:attribute name="rend">
                    <xsl:text>color(</xsl:text>
                    <xsl:value-of select="w:rPr/w:color/@w:val"/>
                    <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="semanticStyle-inner">
                        <xsl:with-param name="style" select="$style"/>
                    </xsl:call-template>
                </hi>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="semanticStyle-inner">
                    <xsl:with-param name="style" select="$style"/>
                </xsl:call-template>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>Map the style name in word to the normalized english type for that
            attribute</xd:desc>
    </xd:doc>
    <xsl:function name="mec:mapStyle" as="xs:string?">
        <xsl:param name="style"/>
        <xsl:choose>
            <xsl:when test="$style=$plantStyle">
                <xsl:value-of select="$plantNameType"/>
            </xsl:when>
            <xsl:when test="$style=$astronomyStyle">
                <xsl:value-of select="$astronomyNameType"/>
            </xsl:when>
            <xsl:when test="$style=$auxSubstStyle">
                <xsl:value-of select="$auxSubstNameType"/>
            </xsl:when>
            <xsl:when test="$style=$textGenreStyle">
                <xsl:value-of select="$textGenreNameType"/>
            </xsl:when>
            <xsl:when test="$style=$illnessesStyle">
                <xsl:value-of select="$illnessesNameType"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>React on the defined styles that have a special meaning qualifying named entities</xd:desc>
    </xd:doc>
    <xsl:template name="semanticStyle-inner">
        <xsl:param name="style"/>
        <xsl:variable name="name" select="string-join(w:t, '')"/>
        <xsl:variable name="commentN" select="(preceding-sibling::w:commentRangeStart)[1]/@w:id" as="xs:string?"/>
        <xsl:variable name="commentNText" select="if (commentN ne '') then $comments/w:comments/w:comment[@w:id=$commentN] else ''" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$style=$nameStyle">
                <xsl:variable name="commentXML">
                    <xsl:call-template name="generatePersonNameXML"/>
                </xsl:variable>
                <xsl:element name="persName">
                    <xsl:attribute name="ref">
                        <xsl:choose>
                            <xsl:when test="empty($commentN)">
                                <xsl:value-of select="mec:getRefIdPerson($name, '', ())"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="mec:getRefIdPerson(($name, $commentXML//tei:addName/text()), $commentN, $commentXML)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style=$placeStyle">
                <xsl:variable name="commentXML">
                    <xsl:call-template name="generatePlaceNameXML"/>
                </xsl:variable>
                <xsl:element name="placeName">
                    <xsl:attribute name="ref">
                        <xsl:choose>
                            <xsl:when test="empty($commentN)">
                                <xsl:value-of select="mec:getRefIdPlace($name, '', ())"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="mec:getRefIdPlace(($name, $commentXML//tei:addName/text()), $commentN, $commentXML)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$style=$otherStyles" >
                <xsl:element name="name">
                    <xsl:variable name="commentXML">
                        <xsl:call-template name="generateOtherNameXML"/>
                    </xsl:variable>
                    <xsl:variable name="ref"
                        select="if (empty($commentN)) then mec:getRefIdOtherNames($name, '', ())
                        else mec:getRefIdOtherNames(($name, $commentXML//tei:orth/text()), $commentN, $commentXML)"/>
                    <xsl:if test="exists($ref)">
                        <xsl:attribute name="ref">
                            <xsl:value-of select="$ref"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="type">
                        <xsl:value-of select="mec:mapStyle($style)"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when> 
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="w:commentReference"/> <!-- suppress -->
        
    <xsl:template name="semanticStyleInfoMissing">
        <xsl:param name="style"/>
        <xsl:variable name="name" select="string-join(w:t, '')"/>
        <xsl:choose>
            <xsl:when test="$style=$nameStyle">
                <xsl:choose>
                    <xsl:when test="exists(mec:getRefIdPerson($name, '', ()))">
                        <xsl:call-template name="semanticStyle">
                            <xsl:with-param name="style" select="$style"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="persName">
                            <note>info missing</note>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$style=$placeStyle">
                <xsl:choose>
                    <xsl:when test="exists(mec:getRefIdPlace($name, '', ()))">
                        <xsl:call-template name="semanticStyle">
                            <xsl:with-param name="style" select="$style"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="placeName">
                            <note>info missing</note>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$style=$otherStyles">
                <xsl:choose>
                    <xsl:when test="exists(mec:getRefIdOtherNames($name, '', ()))">
                        <xsl:call-template name="semanticStyle">
                            <xsl:with-param name="style" select="$style"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="name">
                            <xsl:attribute name="type">
                                <xsl:value-of select="mec:mapStyle($style)"/>
                            </xsl:attribute>
                            <note>info missing</note>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when> 
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Uses a customization in paragraphs.xsl to tap into the docx paragraph processing and simplify the meaning of some styles.
            <xd:p>Note this isn't needed much right now as the styles are propagated to html
            css classes in the end but may be useful later.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="paragraph-wp">
        <xsl:param name="style"/>
        <xsl:choose>
            <xsl:when test="$style='StandardWeb' or $style='Funotentext'">
                <p>
                        <xsl:call-template name="process-checking-for-crossrefs"/>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="paragraph-wp-base">
                    <xsl:with-param name="style" select="$style"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>    
    
    <xd:doc>
        <xd:desc>Retain all used person references</xd:desc>
    </xd:doc>
    <xsl:template match="tei:person[//tei:persName/@ref = @xml:id]" mode="pass2">
        <person>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" mode="pass2"/>
        </person>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Zap unused person referneces</xd:desc>
    </xd:doc>
    <xsl:template match="tei:person" mode="pass2"/>
    
    <xd:doc>
        <xd:desc>Retain all used place references</xd:desc>
    </xd:doc>
    <xsl:template match="tei:place[//tei:placeName/@ref = @xml:id]" mode="pass2">
        <place>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" mode="pass2"/>
        </place>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Zap unused place referneces</xd:desc>
    </xd:doc>
    <xsl:template match="tei:place" mode="pass2"/>
    
    <xd:doc>
        <xd:desc>Retain all used nym references</xd:desc>
    </xd:doc>
    <xsl:template match="tei:nym[//tei:name/@ref = @xml:id]" mode="pass2">
        <nym>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" mode="pass2"/>
        </nym>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Zap unused nym referneces</xd:desc>
    </xd:doc>
    <xsl:template match="tei:nym" mode="pass2"/>
    
    <xd:doc>
        <xd:desc>Zap page breaks not marked with a reference to a particular folio</xd:desc>
    </xd:doc>
    <xsl:template match="tei:pb[not(@n)]" mode="pass2"/>
    
</xsl:stylesheet>