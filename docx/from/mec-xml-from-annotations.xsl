<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:t="urn:mec-xml-from-annotations:test-data"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd t"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>Contains templates that parse annotation strings to generate XML
        </xd:desc>
    </xd:doc>
        
    <xsl:output method="xml" indent="yes"/>
    
    <xd:doc>
        <xd:desc>A string that describes that this data was not determinable
            It separates this entity from another entity where this data is available.
            <xd:p>Note: Whitespace is eliminated before checking against this value.
                So currently this also matches 'n. a. '</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="na" select="'n.a.'"/>
    
    <xd:doc>
        <xd:desc>remark: at the end is split of first so it's easier to have that opional.</xd:desc>
    </xd:doc>
    <xsl:variable name="remarkRegExp">(.*)remark:(.*)</xsl:variable>
    <xsl:variable name="remarkMremains">1</xsl:variable>
    <xsl:variable name="remarkM">2</xsl:variable>
    
    <xd:doc>
        <xd:desc>RegExp for parsing comments describing a person</xd:desc>
    </xd:doc>
    <xsl:variable name="nameRegExp" as="xs:string">^\s*(aka:(.*))?profession:(.*)died:(.*)reign:(.*)</xsl:variable>
    <!-- 1: aka: ... -->
    <xsl:variable name="nameMaka">2</xsl:variable>
    <xsl:variable name="nameMprof">3</xsl:variable>
    <xsl:variable name="nameMdied">4</xsl:variable>
    <xsl:variable name="nameMreign">5</xsl:variable>
    
    <xsl:variable name="nameRegExpRXD" as="xs:string">^\s*(aka:(.*))?profession:(.*)reign:(.*)died:(.*)</xsl:variable>
    <!-- 1: aka: ... -->
    <xsl:variable name="nameMdiedRXD">5</xsl:variable>
    <xsl:variable name="nameMreignRXD">4</xsl:variable>
    
    <t:testData>
        <t:setup>
            <t:thisId>someId</t:thisId>
            <t:type>a type</t:type>
        </t:setup>
        <t:case type="name">
            <t:in>
                <t:wordInText>all specified</t:wordInText>
                <t:annotationText>aka: some aka; some other aka, a third aka profession: some profession died: some day reign: circa 910-931 BC remark: a remark</t:annotationText>
            </t:in>
            <t:expected>
                <person xmlns="http://www.tei-c.org/ns/1.0" xml:id="d1e74">
                    <persName xml:lang="ota-Latn-t">all specified<addName xml:lang="ota-Latn-t">some aka</addName>
                        <addName xml:lang="ota-Latn-t">some other aka</addName>
                        <addName xml:lang="ota-Latn-t">a third aka</addName>
                    </persName>
                    <occupation>some profession</occupation>
                    <death>some day:</death>
                    <floruit from-custom="circa 910" to-custom="931 BC"/>
                    <note>a remark</note>
                </person>
            </t:expected>
        </t:case>
        <t:case type="name">
            <t:in>
                <t:wordInText>no remark</t:wordInText>
                <t:annotationText>aka: some aka profession: some profession died: some day reign: some 10 cents</t:annotationText>
            </t:in>
            <t:expected>
                <person xmlns="http://www.tei-c.org/ns/1.0" xml:id="d1e76">
                    <persName xml:lang="ota-Latn-t">no remark<addName xml:lang="ota-Latn-t">some aka</addName>
                    </persName>
                    <occupation>some profession</occupation>
                    <death>some day</death>
                    <floruit from-custom="some 10 cents"/>
                </person>
            </t:expected>
        </t:case>
        <t:case type="name">
            <t:in>
                <t:wordInText>no aka no remark</t:wordInText>
                <t:annotationText>profession: some profession died: some day reign: some 10 cents</t:annotationText>
            </t:in>
            <t:expected>
                <person xmlns="http://www.tei-c.org/ns/1.0" xml:id="d1e90">
                    <persName xml:lang="ota-Latn-t">no aka no remark</persName>
                    <occupation>some profession</occupation>
                    <death>some day</death>
                    <floruit from-custom="some 10 cents"/>
                </person>
            </t:expected>
        </t:case>
        <t:case type="name">
            <t:in>
                <t:wordInText>garbage</t:wordInText>
                <t:annotationText>profession: garbage demise: garbage</t:annotationText>
            </t:in>
            <t:expected>
                <person xmlns="http://www.tei-c.org/ns/1.0" xml:id="d1e170">
                    <persName>garbage</persName>
                    <note>This name is not annotated correctly! Details: "profession: garbage demise: garbage"</note>
                </person>
            </t:expected>
        </t:case>
        <t:case type="name">
            <t:in>
                <t:wordInText>garbage or typo at the beginning</t:wordInText>
                <t:annotationText>aka; ; is a typo profession: some profession died: some day reign: some 10 cents</t:annotationText>
            </t:in>
            <t:expected>
                <person xmlns="http://www.tei-c.org/ns/1.0" xml:id="d1e195">
                    <persName>garbage or typo at the beginning</persName>
                    <note>This name is not annotated correctly! Details: "aka; ; is a typo profession: some profession died: some day reign: some 10 cents"</note>
                </person>
            </t:expected>
        </t:case> 
        <t:case type="name">
            <t:in>
                <t:wordInText>deid reign exchanged</t:wordInText>
                <t:annotationText>aka: some aka profession: some profession reign: circa 910-931 BC died: some day remark: a remark</t:annotationText>
            </t:in>
            <t:expected> 
                <person xmlns="http://www.tei-c.org/ns/1.0" xml:id="d1e210">
                    <persName xml:lang="ota-Latn-t">deid reign exchanged<addName xml:lang="ota-Latn-t">some aka</addName>
                    </persName>
                    <occupation>some profession</occupation>
                    <death>some day</death>
                    <floruit from-custom="circa 910" to-custom="931 BC"/>
                    <note>a remark</note>
                </person>
            </t:expected>
        </t:case>
        <t:case type="name">
            <t:in>
                <t:wordInText>no annotation</t:wordInText>
                <t:annotationText/>
            </t:in>
            <t:expected>
                <person xmlns="http://www.tei-c.org/ns/1.0" xml:id="d1e195">
                    <persName>garbage or typo at the beginning</persName>
                    <note>This name is not annotated correctly! Details: "aka; ; is a typo profession: some profession died: some day reign: some 10 cents"</note>
                </person>
            </t:expected>
        </t:case>
    </t:testData>
    
    <xd:doc>
        <xd:desc>RegExp for parsing comments describing a place</xd:desc>
    </xd:doc>
    <xsl:variable name="placeRegExp">^\s*(aka:(.*))?type:(.*)where today:(.*)today’s name:(.*)</xsl:variable>
    <!-- 1: aka: ... -->
    <xsl:variable name="placeMaka">2</xsl:variable>
    <xsl:variable name="placeMtype">3</xsl:variable>
    <xsl:variable name="placeMwToday">4</xsl:variable>
    <xsl:variable name="placeMtodayN">5</xsl:variable>
    
    <xd:doc>
        <xd:desc>RegExp for parsing comments describing a various named entities</xd:desc>
    </xd:doc>
    <xsl:variable name="otherRegExp">^\s*(aka:(.*))?Latin:(.*)English:(.*)|(aka:(.*))?English:(.*)</xsl:variable>
    <!-- 1: aka: ... -->
    <xsl:variable name="otherMaka">2</xsl:variable>
    <xsl:variable name="otherMakaAlt">6</xsl:variable>
    <xsl:variable name="otherMlat">3</xsl:variable>
    <xsl:variable name="otherMeng">4</xsl:variable>
    <xsl:variable name="otherMengAlt">7</xsl:variable>
    
    <xd:doc>
        <xd:desc>Try parse a description for a person
            <xd:p>Calls another template that actually generates the XML for describing a person.</xd:p>
        </xd:desc>
    </xd:doc>      
    <xsl:template name="generatePersonNameXML">
        <xsl:param name="thisId" required="yes" as="xs:string?"/>
        <xsl:param name="annotationText" required="yes"/>
        <xsl:param name="wordInText" required="yes" as="xs:string"/>
        <xsl:param name="type" required="yes" as="xs:string?"/>
        <xsl:variable name="generated-id" select="generate-id()"/>
        <xsl:choose>
            <xsl:when test="$annotationText = ''">
                <xsl:call-template name="tagsDeclName">
                    <xsl:with-param name="annotationText" select="' '"/>
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="wordInText" select="$wordInText"/>
                    <xsl:with-param name="generated-id" select="$generated-id"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
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
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Generate a description XML snippet for a person</xd:desc>
    </xd:doc>
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
                            <xsl:if test="replace(., '\s', '') ne $na">
                                <addName xml:lang="ota-Latn-t">                                                    
                                    <xsl:value-of
                                        select="normalize-space(.)"/>
                                </addName>
                            </xsl:if>
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
                    <xsl:call-template name="tagsDeclNameRXD">
                        <xsl:with-param name="type" select="$type"/>
                        <xsl:with-param name="wordInText" select="$wordInText"/>
                        <xsl:with-param name="annotationText" select="$annotationText"/>
                        <xsl:with-param name="remark" select="$remark"/>
                        <xsl:with-param name="generated-id" select="$generated-id"/>
                    </xsl:call-template>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:element>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Workaround for an encoding error: reign and died were exchanged.
            Generate a description XML snippet for a person</xd:desc>
    </xd:doc>
    <xsl:template name="tagsDeclNameRXD">
        <xsl:param name="remark" as="xs:string" select="''"/>
        <xsl:param name="annotationText" as="xs:string"/>
        <xsl:param name="wordInText" as="xs:string"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="generated-id" as="xs:string"/>
        <xsl:analyze-string select="$annotationText"
            regex="{$nameRegExpRXD}">
            <xsl:matching-substring>
                <persName xml:lang="ota-Latn-t">
                    <xsl:value-of select="$wordInText"/>
                    <xsl:for-each select="tokenize(regex-group($nameMaka), '[,;]')">
                        <xsl:if test="replace(., '\s', '') ne $na">
                            <addName xml:lang="ota-Latn-t">                                                    
                                <xsl:value-of
                                    select="normalize-space(.)"/>
                            </addName>
                        </xsl:if>
                    </xsl:for-each>
                </persName>
                <occupation>
                    <xsl:value-of
                        select="normalize-space(regex-group($nameMprof))"/>
                </occupation>
                <death>
                    <xsl:value-of
                        select="normalize-space(regex-group($nameMdiedRXD))"/>
                </death>
                <xsl:if test="normalize-space(regex-group($nameMreignRXD)) != ''">
                    <xsl:variable name="reign" select="normalize-space(regex-group($nameMreignRXD))"/>
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
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Try parse a description for a place
            <xd:p>Calls another template that actually generates the XML for describing a place.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="generatePlaceNameXML">
        <xsl:param name="thisId" required="yes" as="xs:string?"/>
        <xsl:param name="annotationText" required="yes"/>
        <xsl:param name="wordInText" required="yes" as="xs:string"/>
        <xsl:param name="type" required="yes" as="xs:string?"/>
        <xsl:variable name="generated-id" select="generate-id()"/>
        <xsl:choose>
            <xsl:when test="$annotationText = ''">
                <xsl:call-template name="tagsDeclPlace">
                    <xsl:with-param name="annotationText" select="' '"/>
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="wordInText" select="$wordInText"/>
                    <xsl:with-param name="generated-id" select="$generated-id"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
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
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Generate a description XML snippet one of the various named entities</xd:desc>
    </xd:doc>
    <xsl:template name="generateOtherNameXML">
        <xsl:param name="thisId" required="yes" as="xs:string?"/>
        <xsl:param name="annotationText" required="yes"/>
        <xsl:param name="wordInText" required="yes" as="xs:string"/>
        <xsl:param name="type" required="yes" as="xs:string?"/>
        <xsl:variable name="generated-id" select="generate-id()"/>
        <xsl:choose>
            <xsl:when test="$annotationText = ''">               
                <xsl:call-template name="tagsDeclOther">
                    <xsl:with-param name="annotationText" select="' '"/>
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="wordInText" select="$wordInText"/>
                    <xsl:with-param name="generated-id" select="$generated-id"/>
                </xsl:call-template>                
            </xsl:when>
            <xsl:otherwise>                  
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
            </xsl:otherwise>
        </xsl:choose>     
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Generate a description XML snippet for a place</xd:desc>
    </xd:doc>
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
            <xsl:sequence select="$contents/place/@*, $contents/place/node()"/>
        </place>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Generate a description XML snippet for one of the various other entities</xd:desc>
    </xd:doc> 
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
    
    <xsl:template match="t:testData">
        <xsl:apply-templates select="t:case">
            <xsl:with-param name="thisId" select="t:setup/t:thisId" tunnel="yes"/>
            <xsl:with-param name="type" select="t:setup/t:type" tunnel="yes"/>
        </xsl:apply-templates>    
    </xsl:template>
    
    <xsl:template match="t:setup"/>
    
    <xsl:template match="t:case[@type='name']">
        <xsl:param name="thisId" tunnel="yes"/>
        <xsl:param name="type" tunnel="yes"/>
        <xsl:variable name="actual">
            <xsl:call-template name="generatePersonNameXML">
                <xsl:with-param name="thisId" select="$thisId"/>
                <xsl:with-param name="annotationText" select="t:in/t:annotationText"/>
                <xsl:with-param name="wordInText" select="t:in/t:wordInText"/>
                <xsl:with-param name="type" select="$type"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:sequence select="$actual"/>
    </xsl:template>
    
    <xsl:template match="t:case[@type='place']">
        <xsl:param name="thisId" tunnel="yes"/>
        <xsl:param name="type" tunnel="yes"/>
        <xsl:variable name="actual">
            <xsl:call-template name="generatePlaceNameXML">
                <xsl:with-param name="thisId" select="$thisId"/>
                <xsl:with-param name="annotationText" select="t:in/t:annotationText"/>
                <xsl:with-param name="wordInText" select="t:in/t:wordInText"/>
                <xsl:with-param name="type" select="$type"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:sequence select="$actual"/>
    </xsl:template>
    
    <xsl:template match="t:case[@type='other']">
        <xsl:param name="thisId" tunnel="yes"/>
        <xsl:param name="type" tunnel="yes"/>
        <xsl:variable name="actual">
            <xsl:call-template name="generateOtherNameXML">
                <xsl:with-param name="thisId" select="$thisId"/>
                <xsl:with-param name="annotationText" select="t:in/t:annotationText"/>
                <xsl:with-param name="wordInText" select="t:in/t:wordInText"/>
                <xsl:with-param name="type" select="$type"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:sequence select="$actual"/>
    </xsl:template>
    
    <xsl:template match="xsl:stylesheet">
        <div type="testResults">
            <xsl:apply-templates select="t:*"/>
        </div>
    </xsl:template>
    
</xsl:stylesheet>