<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mec="http://mecmua.priv" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:local="urn:local"
    xmlns:t="urn:generate-common-tagsDecl-unify:test-data"
    exclude-result-prefixes="xs xd mec tei local t" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>Code that unifies two annotations for an entity </xd:desc>
    </xd:doc>

<!--        <xsl:include href="mec-descr-processing.xsl"/>-->

    <xsl:include href="uri-decode-helper.xsl"/>

    <xd:doc>
        <xd:desc>Gets all names from all annotations to the top</xd:desc>
        <xd:param name="c">tei:person|tei:place|tei:item</xd:param>
    </xd:doc>
    <xsl:template name="unify-prepare">
        <xsl:param name="c"/>
        <xsl:for-each-group select="$c" group-by="local:gen-group-key(.)">
            <xsl:apply-templates select="." mode="unify-prepare">
                <xsl:with-param name="group-key" select="current-grouping-key()"/>
                <xsl:with-param name="whole-group" select="current-group()"/>
            </xsl:apply-templates>
        </xsl:for-each-group>
    </xsl:template>
    
    <t:testData>
        <t:case type="group-key">
            <t:in>
                <t:c xmlns="http://www.tei-c.org/ns/1.0">                    
                    <person xml:id="d27e20063">
                        <persName xml:lang="ota-Latn-t" type="preferred">Ḥasan</persName>
                        <persName xml:lang="ota-Latn-t" type="variant">Ḥasan-i Baṣrī</persName>
                        <occupation/>
                        <death/>
                        <note>identity is not determinable</note>
                    </person>
                </t:c>
            </t:in>
            <t:expected>identity is not determinableḤasanḤasan-i Baṣrī</t:expected>
        </t:case>
        <t:case type="group-key">
            <t:in>
                <t:c xmlns="http://www.tei-c.org/ns/1.0">                   
                    <item xml:id="d27e75146">
                        <name xml:lang="ota-Latn-t" type="variant">s-n-ḫām</name>
                        <name xml:lang="ota-Latn-t" type="variant">rūmī qūqīyā</name>
                        <cit type="translation">
                            <sense xml:lang="la">n.a.</sense>
                            <sense xml:lang="en-UK">not determinable</sense>
                        </cit>
                    </item>
                </t:c>
            </t:in>
            <t:expected>n.a.not determinables-n-ḫāmrūmī qūqīyā</t:expected>
        </t:case>
        <t:case type="group-key">
            <t:in>
                <t:c xmlns="http://www.tei-c.org/ns/1.0">
                    <person xml:id="d25e57">
                        <persName xml:lang="ota-Latn-t" type="variant">Muḥammad</persName>
                        <persName xml:lang="ota-Latn-t" type="variant">Muḥammed Muṣṭafā</persName>
                        <persName xml:lang="ota-Latn-t" type="variant">Muḥammed</persName>
                        <occupation>the Prophet of Islam</occupation>
                        <death>632</death>
                        <floruit from-custom="n.a."/>
                    </person>                    
                </t:c>
            </t:in>
            <t:expected>the Prophet of Islam632n.a.</t:expected>
        </t:case>
        <t:case type="group-key">
            <t:in>
                <t:c xmlns="http://www.tei-c.org/ns/1.0">                
                    <person xml:id="d25e334">
                        <persName xml:lang="ota-Latn-t" type="variant">Kenʿān Paşa</persName>
                        <persName xml:lang="ota-Latn-t" type="variant">Kenʿān // Paşa</persName>
                        <occupation>vizier</occupation>
                        <death>n.a.</death>
                        <floruit from-custom="n.a."/>
                        <note>identity is not determinable definitely; at least two persons who could come into consideration: cf. Sicill‑i ʿOs̱mānī (1996), 3, p. 884f., s.v. Ken'an Paşa and Ken'an Paşa (Sarı) (Topal); EI2, s.v. Kenʿān Pasha,  test</note>
                    </person>
                </t:c>
            </t:in>
            <t:expected>viziern.a.n.a.s.v. Kenʿān Pasha</t:expected>
        </t:case>
        <t:case type="group-key">
            <t:in>
                <t:c xmlns="http://www.tei-c.org/ns/1.0">
                    <person xml:id="d25e308">
                        <persName xml:lang="ota-Latn-t" type="variant">Muṣṭafā</persName>
                        <occupation>n.a.</occupation>
                        <death>n.a.</death>
                        <floruit from-custom="n.a."/>
                        <note>identity is not determinable definitely; from the text we only understand that he is from İstolnī Belġrād and made the pilgrimage</note>
                    </person>
                </t:c>
            </t:in>
            <t:expected>n.a.n.a.n.a.Muṣṭafā</t:expected>
        </t:case>
        <t:case type="group-key">
            <t:in>
                <t:c xmlns="http://www.tei-c.org/ns/1.0">
                    <person xml:id="d25e1301">
                        <persName xml:lang="ota-Latn-t" type="variant">Ẕeyd</persName>
                        <occupation>n.a.</occupation>
                        <death>n.a.</death>
                        <floruit from-custom="n.a."/>
                        <note>Alias for an involved party occurring in a fatwa</note>
                    </person>
                </t:c>
            </t:in>
            <t:expected>n.a.n.a.n.a.Ẕeyd</t:expected>
        </t:case>
        <t:case type="group-key">
            <t:in>
                <t:c xmlns="http://www.tei-c.org/ns/1.0">
                    <person xml:id="d25e90546">
                        <persName xml:lang="ota-Latn-t" type="variant">Kākāʾil</persName>
                        <occupation>angel</occupation>
                        <death>n.a.</death>
                        <floruit from-custom="n.a."/>
                    </person>
                </t:c>
            </t:in>
            <t:expected>angeln.a.n.a.Kākāʾil</t:expected>
        </t:case>
        <t:case type="group-key">
            <t:in>
                <t:c xmlns="http://www.tei-c.org/ns/1.0">
                    <place xml:id="d25e116889" type="unknown">
                        <placeName xml:lang="ota-Latn-t" type="variant">...</placeName>
                        <location>
                            <country/>
                        </location>
                    </place>
                </t:c>
            </t:in>
            <t:expected>unknown...</t:expected>
        </t:case>
        <t:case type="group-key">
            <t:in>
                <t:c xmlns="http://www.tei-c.org/ns/1.0">
                    <person xml:id="d25e68852">
                        <persName xml:lang="ota-Latn-t" type="variant">Muḥammed</persName>
                        <persName xml:lang="ota-Latn-t" type="variant">Muḥammed bin Tekiş</persName>
                        <occupation>Ḫvārezm Shah</occupation>
                        <death>1220</death>
                        <floruit from-custom="1200" to-custom="1220"/>
                        <note>Cf. EI2, IV, s.v. Khwārazm-Shāhs</note>
                    </person>
                </t:c>
            </t:in>
            <t:expected>Ḫvārezm Shah122012001220s.v. Khwārazm-Shāhs</t:expected>
        </t:case>
        <t:case type="group-key">
            <t:in>
                <t:c xmlns="http://www.tei-c.org/ns/1.0">
                    <place xml:id="d25e36444" type="halting_place__residence">
                        <placeName xml:lang="ota-Latn-t" type="variant">Elmalu</placeName>
                        <placeName xml:lang="en-UK">n.a.</placeName>
                        <location>
                            <country>n.a.</country>
                        </location>
                        <note>place is not determinable</note>
                    </place>
                </t:c>
            </t:in>
            <t:expected>halting_place__residencen.a.n.a.Elmalun.a.</t:expected>
        </t:case>
    </t:testData>

    <xsl:function name="local:gen-group-key" as="xs:string">
        <xsl:param name="c"/>
        <xsl:variable name="personKey" select="concat($c/tei:occupation, $c/tei:death, $c/*/@from-custom, $c/*/@to-custom)" as="xs:string"/>
        <xsl:variable name="placeKey" select="concat($c/@type, $c/tei:placeName[@xml:lang = 'en-UK'], $c/tei:location/tei:country)" as="xs:string"/>
        <xsl:variable name="otherKey" select="string-join($c/tei:cit/tei:sense, '')" as="xs:string"/>
        <xsl:variable name="nameKeyIfIdentityUndeterminable" select="if (lower-case($c/tei:note) eq 'not determinable' or 
                                                                         lower-case($c//tei:sense[@xml:lang eq 'en-UK']) eq 'not determinable' or
                                                                         contains(lower-case($c/tei:occupation), 'angel') or
                                                                         contains(lower-case($c/tei:note), 'identity is not determinable') or
                                                                         contains(lower-case($c/tei:note), 'place is not determinable') or
                                                                         contains(lower-case($c/tei:note), 'involved party occurring in a fatwa') or
                                                                         $c/@type eq 'unknown')
                                                                     then string-join($c/(tei:persName|tei:placeName|tei:name), '') 
                                                                     else ()" as="xs:string?"/>
        <xsl:variable name="noteKeyIfNotDeterminable" select="if (contains($c/tei:note, 'not determinable')) then $c/tei:note else ()" as="xs:string?"/>
        <xsl:variable name="SVKey" select="if (contains($c/tei:note, 's.v.')) then replace($c/tei:note, '^.*(s\.v\.[^\.,]*)[\.,]?.*$', '$1') else ()" as="xs:string?"/>
        <xsl:value-of select="concat($personKey, $placeKey, $otherKey,
            if ($SVKey) then $SVKey 
            else if ($nameKeyIfIdentityUndeterminable) then $nameKeyIfIdentityUndeterminable 
            else $noteKeyIfNotDeterminable)"
        />
    </xsl:function>

    <xsl:template match="tei:person | tei:place | tei:item" mode="unify-prepare">
        <xsl:param name="group-key" select="''"/>
        <xsl:param name="whole-group" select="()"/>
        <xsl:variable name="this" select="."/>
        <xsl:variable name="names">
            <xsl:for-each-group select="$whole-group//(tei:persName | tei:placeName | tei:name)"
                group-by="concat(mec:getLcName(.), @xml:lang)">
                <xsl:copy-of select="."/>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:variable name="ret">
            <xsl:choose>
                <xsl:when test="$group-key ne '' and not(matches($group-key, '^(n\.a\.)+$'))">
                    <xsl:variable name="firstElementCombined">
                        <xsl:element name="{local-name()}" namespace="{namespace-uri()}">
                            <!-- Use for debugging only                    <xsl:attribute name="group-key">
                        <xsl:value-of select="$group-key"/>
                    </xsl:attribute>-->
                            <xsl:apply-templates
                                select="(@*, $names, * except (tei:persName | tei:placeName | tei:name) | text() | processing-instruction() | comment())"
                                mode="#current"/>
                        </xsl:element>
                    </xsl:variable>
                    <xsl:variable name="otherElements">
                        <xsl:for-each select="$whole-group except .">
                            <xsl:element name="{local-name()}" namespace="{namespace-uri()}">
<!--                                <xsl:attribute name="group-key">
                                    <xsl:value-of select="$group-key"/>
                                </xsl:attribute>  -->                       
                                <xsl:sequence
                                    select="@* | (tei:persName | tei:placeName | tei:name)[1] | * except (tei:persName | tei:placeName | tei:name | tei:note)"/>
                                <note xmlns="http://www.tei-c.org/ns/1.0">not annotated annotation moved</note>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:sequence select="($firstElementCombined, $otherElements)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$whole-group"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$ret"/>
    </xsl:template>

    <t:testData_>
        <t:case type="unify">
            <t:in>
                <t:indexListsPreparedDoc>tests/mec-descr-processing/tagsDecl-Bsp.xml</t:indexListsPreparedDoc>
                <t:copyUsed>false</t:copyUsed>
            </t:in>
            <t:expected/>
        </t:case>
    </t:testData_>

    <xsl:template match="tei:listPerson | tei:listPlace | tei:list" mode="unify">
        <xsl:param name="indexListsPrepared" tunnel="yes"/>
        <xsl:variable name="prepared" as="element()">
            <xsl:element name="{local-name()}" namespace="{namespace-uri()}">                
                <xsl:sequence select="@*"/>
                <xsl:call-template name="unify-prepare">
                    <xsl:with-param name="c"
                        select="$indexListsPrepared//(tei:person | tei:place | tei:item)"/>
                </xsl:call-template>
            </xsl:element>
        </xsl:variable>
        <xsl:element name="{local-name()}" namespace="{namespace-uri()}">
            <xsl:sequence select="@*"/>
            <xsl:apply-templates mode="unify">
                <xsl:with-param name="indexListsPrepared" select="$prepared" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xd:doc>
        <xd:desc>The person is checked against the second list of persons. If copyUsed is true then
            everything is copied (what do I need this for then? Is this the point to merge
            information found in the current document?) If copyUsed is false all similar persons are
            skipped. </xd:desc>
    </xd:doc>
    <xsl:template match="tei:person | tei:place | tei:item" mode="unify">
        <xsl:param name="group-key" select="''"/>
        <xsl:param name="copyUsed" select="true()" tunnel="yes" as="xs:boolean"/>
        <xsl:param name="indexListsPrepared" required="yes" tunnel="yes" as="element()"/>
        <xsl:variable name="existingUnifiedRefId">
            <xsl:choose>
                <xsl:when test=". instance of element(tei:person)">
                    <xsl:value-of
                        select="mec:getRefIdPerson(mec:trimEntAttr((tei:persName[not(mec:trimEntAttr(.) = 'n.a.')])), '???', ., $indexListsPrepared)"
                    />
                </xsl:when>
                <xsl:when test=". instance of element(tei:place)">
                    <xsl:value-of
                        select="mec:getRefIdPlace(mec:trimEntAttr((tei:placeName[not(mec:trimEntAttr(.) = 'n.a.')])), '???', ., $indexListsPrepared)"
                    />
                </xsl:when>
                <xsl:when test=". instance of element(tei:item)">
                    <xsl:value-of
                        select="mec:getRefIdOtherNames(mec:trimEntAttr(tei:name[not(mec:trimEntAttr(.) = 'n.a.')]), '???', ., $indexListsPrepared)"
                    />
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="externalDecl" select="$indexListsPrepared//*[@xml:id = $existingUnifiedRefId]"/>
        <xsl:variable name="group-key"
            select="$indexListsPrepared//*[@xml:id = $existingUnifiedRefId]/@group-key"/>
        <xsl:variable name="externalIsLocal"
            select="local:createUniID(/, @xml:id) eq data($externalDecl/@xml:id)[1]"/>
        <xsl:copy>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="$existingUnifiedRefId"/>
            </xsl:attribute>
            <xsl:attribute name="copyOf">
                <xsl:value-of select="data(@xml:id)"/>
            </xsl:attribute>
            <xsl:if test="$group-key">
                <xsl:attribute name="group-key">
                    <xsl:value-of select="data($group-key)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates
                select="(@* except (@xml:id | @copyOf)) | * | text() | processing-instruction() | comment()"
                mode="unify">
                <xsl:with-param name="externalDecl"
                    select="
                        if ($externalIsLocal) then
                            ()
                        else
                            $externalDecl"
                    tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>


    <xd:doc>
        <xd:desc>Removes trailing whitespace only.</xd:desc>
    </xd:doc>
    <xsl:function name="mec:trimEntAttr" as="xs:string*">
        <xsl:param name="nodesToClean" as="element()*"/>
        <xsl:for-each select="($nodesToClean | $nodesToClean//*)">
            <xsl:variable name="trimmedText" select="replace(string-join(./text(), ''), '\s+$', '')"/>
            <xsl:if test="$trimmedText ne ''">
                <xsl:value-of select="$trimmedText"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function> 
    <xd:doc>
        <xd:desc>Lowercases a word or first character of a phrase</xd:desc>
    </xd:doc>
    <xsl:function name="mec:getLcName" as="xs:string+">
        <xsl:param name="name" as="xs:string+"/>
        <xsl:for-each select="$name">
            <xsl:value-of select="concat(lower-case(substring(., 1, 1)), substring(., 2))"/>
        </xsl:for-each>
    </xsl:function>
    <xsl:template match="tei:persName[position() = last()] | tei:placeName[position() = last()]"
        mode="unify">
        <xsl:param name="externalDecl" tunnel="yes"/>
        <xsl:variable name="ret" as="element()*">
            <xsl:if test="exists($externalDecl)">
                <xsl:variable name="this" select="."/>
                <xsl:variable name="thisName" select="QName(namespace-uri(.), local-name(.))"/>
                <xsl:variable name="thisTexts"
                    select="mec:trimEntAttr($this/../*[QName(namespace-uri(), local-name()) eq $thisName])"/>
                <xsl:variable name="externalData"
                    select="$externalDecl//*[QName(namespace-uri(), local-name()) eq $thisName and not(mec:trimEntAttr(.) = $thisTexts) and @xml:lang eq 'ota-Latn-t']"/>
                <xsl:for-each select="$externalData">
                    <xsl:element name="{./local-name()}" namespace="{./namespace-uri()}">
                        <xsl:attribute name="xml:lang">ota-Latn-t</xsl:attribute>
                        <xsl:attribute name="type">variant</xsl:attribute>
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
        <xsl:sequence select="."/>
        <xsl:sequence select="$ret"/>
    </xsl:template>

    <xsl:template match="tei:name[position() = last()]" mode="unify">
        <xsl:param name="externalDecl" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="exists($externalDecl)">
                <xsl:variable name="this" select="."/>
                <xsl:variable name="thisTexts" select="mec:trimEntAttr($this)"/>
                <xsl:variable name="externalData" select="$externalDecl//tei:name"/>
                <xsl:variable name="ret">
                <xsl:copy>
                    <xsl:sequence select="@*"/>
                    <xsl:apply-templates mode="unify"/>
                    <xsl:apply-templates mode="unify"
                        select="$externalData[not(mec:trimEntAttr(.) = $thisTexts)]/*"/>
                </xsl:copy>
                </xsl:variable>
                <xsl:sequence select="$ret"/>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>Copy anything else in unify mode.</xd:desc>
    </xd:doc>
    <xsl:template match="@* | * | processing-instruction() | comment()" mode="unify unify-prepare">
        <xsl:copy>
            <xsl:apply-templates select="* | @* | text() | processing-instruction() | comment()"
                mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:function name="local:createUniID">
        <xsl:param name="doc" as="document-node()"/>
        <xsl:param name="idInDocument" as="xs:string"/>
        <xsl:variable name="documentName" as="xs:string"
            select="replace(document-uri($doc), '([^/]+/)+(.*)\.xml$', '$2')"/>
        <xsl:variable name="documentNameDecoded" as="xs:string"
            select="local:pct-decode($documentName)"/>
        <xsl:value-of select="concat('uni_', $documentNameDecoded, '_', $idInDocument)"/>
    </xsl:function>

    <xsl:template match="t:testData">
        <xsl:apply-templates select="t:case"/>
    </xsl:template>

    <xsl:template match="t:setup"/>

    <xsl:template match="t:case[@type = 'unify']">
        <xsl:variable name="indexListsPrepared" select="doc(t:in/t:indexListsPreparedDoc)/*"/>
        <!--        <xsl:variable name="actual">-->
        <xsl:apply-templates select="$indexListsPrepared" mode="unify">
            <xsl:with-param name="indexListsPrepared" select="$indexListsPrepared" tunnel="yes"/>
            <xsl:with-param name="copyUsed" select="t:in/t:copyUsed" tunnel="yes"/>
        </xsl:apply-templates>
        <!--        </xsl:variable>
        <xsl:if test="t:expected ne $actual">
            <div type="case">
                <xsl:sequence select="(data(t:in/t:comment/*/@xml:id), $actual)"/>
            </div>
        </xsl:if>-->
    </xsl:template>
        
    <xsl:template match="t:case[@type = 'group-key']">
        <xsl:variable name="actual" select="local:gen-group-key(t:in/t:c/*)"/>
        <xsl:if test="t:expected ne $actual">
            <xsl:value-of select="concat('group-key should be ', t:expected, ' was ', $actual)"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="xsl:stylesheet">
        <div type="testResults">
            <xsl:apply-templates select="t:testData"/>
        </div>
    </xsl:template>

</xsl:stylesheet>