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
                <person xml:id="d1e85">
                    <persName xml:lang="ota-Latn-t" type="variant">all specified</persName>
                    <persName xml:lang="ota-Latn-t" type="variant">some aka</persName>
                    <persName xml:lang="ota-Latn-t" type="variant">some other aka</persName>
                    <persName xml:lang="ota-Latn-t" type="variant">a third aka</persName>
                    <occupation>some profession</occupation>
                    <death>some day</death>
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
                <person xml:id="d1e126">
                    <persName xml:lang="ota-Latn-t" type="variant">no remark</persName>
                    <persName xml:lang="ota-Latn-t" type="variant">some aka</persName>
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
                <person xml:id="d1e158">
                    <persName xml:lang="ota-Latn-t" type="variant">no aka no remark</persName>
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
                <person xml:id="d1e187">
                    <persName xml:lang="ota-Latn-t">garbage</persName>
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
                <person xml:id="d1e212">
                    <persName xml:lang="ota-Latn-t">garbage or typo at the beginning</persName>
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
                <person xml:id="d1e236">
                    <persName xml:lang="ota-Latn-t">deid reign exchanged</persName>
                    <persName xml:lang="ota-Latn-t" type="variant">some aka</persName>
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
                <person xml:id="d1e271">
                    <persName xml:lang="ota-Latn-t">no annotation</persName>
                    <note>This name is not annotated! No annotation found.</note>
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
    
    <t:testData>
        <t:setup>
            <t:thisId>someId</t:thisId>
            <t:type>a type</t:type>
        </t:setup>
        <t:case type="place">
            <t:in>
                <t:wordInText>all specified</t:wordInText>
                <t:annotationText>aka: some aka; some other aka, a third aka type: someTypeOfGeoEnt where today: some country today’s name: how it is called today remark: a remark</t:annotationText>
            </t:in>
            <t:expected>
                <place xml:id="d1e330" type="someTypeOfGeoEnt">
                    <placeName xml:lang="ota-Latn-t" type="variant">all specified</placeName>
                    <placeName xml:lang="ota-Latn-t" type="variant">some aka</placeName>
                    <placeName xml:lang="ota-Latn-t" type="variant">some other aka</placeName>
                    <placeName xml:lang="ota-Latn-t" type="variant">a third aka</placeName>
                    <placeName xml:lang="en-UK">how it is called today</placeName>
                    <location>
                        <country>some country</country>
                    </location>
                    <note>a remark</note>
                </place>
            </t:expected>
        </t:case>
        <t:case type="place">
            <t:in>
                <t:wordInText>no aka, no remark</t:wordInText>
                <t:annotationText>type: someTypeOfGeoEnt where today: some country today’s name: how it is called today</t:annotationText>
            </t:in>
            <t:expected>
                <place xml:id="d1e372" type="someTypeOfGeoEnt">
                    <placeName xml:lang="ota-Latn-t" type="variant">no aka, no remark</placeName>
                    <placeName xml:lang="en-UK">how it is called today</placeName>
                    <location>
                        <country>some country</country>
                    </location>
                </place>
            </t:expected>
        </t:case>
        <t:case type="place">
            <t:in>
                <t:wordInText>garbage</t:wordInText>
                <t:annotationText>today: some country today’s name: how it is called today</t:annotationText>
            </t:in>
            <t:expected>
                <place>
                    <placeName xml:lang="ota-Latn-t">garbage</placeName>
                    <note>This name is not annotated correctly! Details: "today: some country today’s name: how it is called today"</note>
                </place>
            </t:expected>
        </t:case>
    </t:testData>
    
    <xd:doc>
        <xd:desc>RegExp for parsing comments describing a various named entities</xd:desc>
    </xd:doc>
    <xsl:variable name="otherRegExp">^\s*(aka:(.*))?Latin:(.*)English:(.*)|^\s*(aka:(.*))?English:(.*)</xsl:variable>
    <!-- 1: aka: ... -->
    <xsl:variable name="otherMaka">2</xsl:variable>
    <xsl:variable name="otherMakaAlt">6</xsl:variable>
    <xsl:variable name="otherMlat">3</xsl:variable>
    <xsl:variable name="otherMeng">4</xsl:variable>
    <xsl:variable name="otherMengAlt">7</xsl:variable>
    
    <t:testData>
        <t:setup>
            <t:thisId>someId</t:thisId>
<!--            <t:type>a Type</t:type> Items are split in different lists per type!-->
        </t:setup>
        <t:case type="other">
            <t:in>
                <t:wordInText>all specified</t:wordInText>
                <t:annotationText>aka: some aka; some other aka, a third aka Latin: nomen latinum English: some English name remark: a remark</t:annotationText>
            </t:in>
            <t:expected>
                <item xml:id="d1e468">
                    <name xml:lang="ota-Latn-t" type="variant">all specified</name>
                    <name xml:lang="ota-Latn-t" type="variant">some aka</name>
                    <name xml:lang="ota-Latn-t" type="variant">some other aka</name>
                    <name xml:lang="ota-Latn-t" type="variant">a third aka</name>
                    <cit type="translation">
                        <sense xml:lang="la">nomen latinum</sense>
                        <sense xml:lang="en-UK">some English name</sense>
                    </cit>
                    <note>a remark</note>
                </item>
            </t:expected>
        </t:case>
        <t:case type="other">
            <t:in>
                <t:wordInText>no aka, no remark</t:wordInText>
                <t:annotationText>Latin: nomen latinum English: some English name</t:annotationText>
            </t:in>
            <t:expected>
                <item xml:id="d1e511">
                    <name xml:lang="ota-Latn-t" type="variant">no aka, no remark</name>
                    <cit type="translation">
                        <sense xml:lang="la">nomen latinum</sense>
                        <sense xml:lang="en-UK">some English name</sense>
                    </cit>
                </item>
            </t:expected>
        </t:case>
        <t:case type="other">
            <t:in>
                <t:wordInText>no aka, no remark, no Latin</t:wordInText>
                <t:annotationText>English: some English name</t:annotationText>
            </t:in>
            <t:expected>
                <item xml:id="d1e538">
                    <name xml:lang="ota-Latn-t" type="variant">no aka, no remark, no Latin</name>
                    <cit type="translation">
                        <sense xml:lang="en-UK">some English name</sense>
                    </cit>
                </item>
            </t:expected>
        </t:case>
        <t:case type="other">
            <t:in>
                <t:wordInText>garbage</t:wordInText>
                <t:annotationText>aka: some aka Deutsch: irgendwas</t:annotationText>
            </t:in>
            <t:expected>
                <item xml:id="d1e562">
                    <name xml:lang="ota-Latn-t" type="variant">garbage</name>
                    <note>This name is not annotated correctly! Details: "aka: some aka Deutsch: irgendwas"</note>
                </item>
            </t:expected>
        </t:case>
        <t:case type="other">
            <t:in>
                <t:wordInText>garbage in aka</t:wordInText>
                <t:annotationText>aka : some aka English: some English name</t:annotationText>
            </t:in>
            <t:expected>
                <item xml:id="d1e590">
                    <name xml:lang="ota-Latn-t" type="variant">garbage in aka</name>
                    <note>This name is not annotated correctly! Details: "aka : some aka English: some English name"</note>
                </item>
            </t:expected>
        </t:case>
    </t:testData>
    
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
                <xsl:call-template name="tagsIndexItemName">
                    <xsl:with-param name="annotationText" select="' '"/>
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="wordInText" select="$wordInText"/>
                    <xsl:with-param name="generated-id" select="$generated-id"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:analyze-string select="$annotationText" regex="{$remarkRegExp}">
                    <xsl:matching-substring>
                        <xsl:call-template name="tagsIndexItemName">
                            <xsl:with-param name="remark"><xsl:value-of select="normalize-space(regex-group($remarkM))"/></xsl:with-param>
                            <xsl:with-param name="annotationText"><xsl:value-of select="normalize-space(regex-group($remarkMremains))"/></xsl:with-param>
                            <xsl:with-param name="type" select="$type"/>
                            <xsl:with-param name="wordInText" select="$wordInText"/>
                            <xsl:with-param name="generated-id" select="$generated-id"/>
                        </xsl:call-template>                                           
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:call-template name="tagsIndexItemName">
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
    <xsl:template name="tagsIndexItemName">
        <xsl:param name="remark" as="xs:string" select="''"/>
        <xsl:param name="annotationText" as="xs:string"/>
        <xsl:param name="wordInText" as="xs:string"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="generated-id" as="xs:string"/>
        <person>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="$generated-id"/>
            </xsl:attribute>
            <xsl:analyze-string select="$annotationText"
                regex="{$nameRegExp}">
                <xsl:matching-substring>
                    <persName xml:lang="ota-Latn-t" type="variant">
                        <xsl:value-of select="$wordInText"/>
                    </persName>
                    <xsl:for-each select="tokenize(regex-group($nameMaka), '[,;]')">
                        <xsl:if test="replace(., '\s', '') ne $na">
                            <persName xml:lang="ota-Latn-t" type="variant">                                                    
                                <xsl:value-of
                                    select="normalize-space(.)"/>
                            </persName>
                        </xsl:if>
                    </xsl:for-each>
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
                    <xsl:call-template name="tagsIndexItemNameRXD">
                        <xsl:with-param name="type" select="$type"/>
                        <xsl:with-param name="wordInText" select="$wordInText"/>
                        <xsl:with-param name="annotationText" select="$annotationText"/>
                        <xsl:with-param name="remark" select="$remark"/>
                        <xsl:with-param name="generated-id" select="$generated-id"/>
                    </xsl:call-template>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </person>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Workaround for an encoding error: reign and died were exchanged.
            Generate a description XML snippet for a person</xd:desc>
    </xd:doc>
    <xsl:template name="tagsIndexItemNameRXD">
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
                </persName>
                <xsl:for-each select="tokenize(regex-group($nameMaka), '[,;]')">
                    <xsl:if test="replace(., '\s', '') ne $na">
                        <persName xml:lang="ota-Latn-t" type="variant">                                                    
                            <xsl:value-of
                                select="normalize-space(.)"/>
                        </persName>
                    </xsl:if>
                </xsl:for-each>
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
                <persName xml:lang="ota-Latn-t">
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
                <xsl:call-template name="tagsIndexItemPlace">
                    <xsl:with-param name="annotationText" select="' '"/>
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="wordInText" select="$wordInText"/>
                    <xsl:with-param name="generated-id" select="$generated-id"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:analyze-string select="$annotationText" regex="{$remarkRegExp}">
                    <xsl:matching-substring>
                        <xsl:call-template name="tagsIndexItemPlace">
                            <xsl:with-param name="remark"><xsl:value-of select="normalize-space(regex-group($remarkM))"/></xsl:with-param>
                            <xsl:with-param name="annotationText"><xsl:value-of select="normalize-space(regex-group($remarkMremains))"/></xsl:with-param>
                            <xsl:with-param name="type" select="$type"/>
                            <xsl:with-param name="wordInText" select="$wordInText"/>
                            <xsl:with-param name="generated-id" select="$generated-id"/>
                        </xsl:call-template>                                           
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:call-template name="tagsIndexItemPlace">
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
    <xsl:template name="tagsIndexItemPlace">
        <xsl:param name="remark" as="xs:string" select="''"/>
        <xsl:param name="annotationText" as="xs:string"/>
        <xsl:param name="wordInText" as="xs:string"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="generated-id" as="xs:string"/>
        <place>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="$generated-id"/>
            </xsl:attribute>
            <xsl:analyze-string select="$annotationText" regex="{$placeRegExp}">
                <xsl:matching-substring>
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="$generated-id"/>
                    </xsl:attribute>
                    <xsl:attribute name="type">
                        <xsl:value-of
                            select="if (normalize-space(regex-group($placeMtype)) ne '') then replace(normalize-space(regex-group($placeMtype)), '[ ;,:]', '_') else 'unknown'"
                        />
                    </xsl:attribute>
                    <placeName xml:lang="ota-Latn-t" type="variant">
                        <xsl:value-of select="$wordInText"/>
                    </placeName>
                    <xsl:for-each select="tokenize(regex-group($placeMaka), '[,;]')">
                        <placeName xml:lang="ota-Latn-t" type="variant">
                            <xsl:value-of select="normalize-space(.)"/>
                        </placeName>
                    </xsl:for-each>
                    <placeName xml:lang="en-UK">
                        <xsl:value-of select="normalize-space(regex-group($placeMtodayN))"/>
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
                    
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <placeName xml:lang="ota-Latn-t">
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
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </place>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Generate a description XML snippet one of the various named entities</xd:desc>
    </xd:doc>
    <xsl:template name="generateOtherNameXML">
        <xsl:param name="thisId" required="yes" as="xs:string?"/>
        <xsl:param name="annotationText" required="yes"/>
        <xsl:param name="wordInText" required="yes" as="xs:string"/>
        <xsl:variable name="generated-id" select="generate-id()"/>
        <xsl:choose>
            <xsl:when test="$annotationText = ''">               
                <xsl:call-template name="tagsIndexItemOther">
                    <xsl:with-param name="annotationText" select="' '"/>
                    <xsl:with-param name="wordInText" select="$wordInText"/>
                    <xsl:with-param name="generated-id" select="$generated-id"/>
                </xsl:call-template>                
            </xsl:when>
            <xsl:otherwise>                  
                <xsl:analyze-string select="$annotationText" regex="{$remarkRegExp}">
                    <xsl:matching-substring>
                        <xsl:call-template name="tagsIndexItemOther">
                            <xsl:with-param name="remark" select="normalize-space(regex-group($remarkM))"/>
                            <xsl:with-param name="annotationText" select="normalize-space(regex-group($remarkMremains))"/>
                            <xsl:with-param name="wordInText" select="$wordInText"/>
                            <xsl:with-param name="generated-id" select="$generated-id"/>
                        </xsl:call-template>                                           
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:call-template name="tagsIndexItemOther">
                            <xsl:with-param name="annotationText"><xsl:value-of select="$annotationText"/></xsl:with-param>
                            <xsl:with-param name="wordInText" select="$wordInText"/>
                            <xsl:with-param name="generated-id" select="$generated-id"/>
                        </xsl:call-template>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>                
            </xsl:otherwise>
        </xsl:choose>     
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Generate a description XML snippet for one of the various other entities</xd:desc>
    </xd:doc> 
    <xsl:template name="tagsIndexItemOther">
        <xsl:param name="remark" as="xs:string" select="''"/>
        <xsl:param name="annotationText" as="xs:string"/>
        <xsl:param name="wordInText" as="xs:string"/>
        <xsl:param name="generated-id" as="xs:string"/>
        <item>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="$generated-id"/>
            </xsl:attribute>
            <!--            <orth xml:lang="ota-Latn-t">
                <xsl:value-of select="$wordInText"/>
            </orth>-->
            <!--            <xsl:if test="lower-case($wordInText) ne $wordInText">-->
            <name xml:lang="ota-Latn-t" type="variant">
                <xsl:value-of select="concat(lower-case(substring($wordInText, 1, 1)), substring($wordInText, 2))"/>    
            </name>
            <!--            </xsl:if>-->
            <xsl:analyze-string select="$annotationText" regex="{$otherRegExp}">
                <xsl:matching-substring>
                    <xsl:for-each select="tokenize(if (regex-group($otherMaka) eq '') then regex-group($otherMakaAlt) else regex-group($otherMaka), '[,;]')">
                        <name xml:lang="ota-Latn-t" type="variant">                                                    
                            <xsl:value-of
                                select="normalize-space(.)"/>
                        </name>
                    </xsl:for-each>
                    <cit type="translation">
                    <xsl:if test="regex-group($otherMeng) ne ''">
                        <sense xml:lang="la">
                            <xsl:value-of select="normalize-space(regex-group($otherMlat))"/>
                        </sense>
                    </xsl:if>
                    <sense xml:lang="en-UK">
                        <xsl:value-of select="normalize-space(if (regex-group($otherMeng) eq '') then regex-group($otherMengAlt) else regex-group($otherMeng))"/>
                    </sense>
                    </cit>
                    <xsl:if test="$remark ne ''">
                        <note>
                            <xsl:value-of select="$remark"/>
                        </note>
                    </xsl:if>
                </xsl:matching-substring>                                            
                <xsl:non-matching-substring>
                    <note>
                        <xsl:choose>
                            <xsl:when test="$annotationText = ' '">
                                This name is not annotated! No annotation found.
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="concat('This name is not annotated correctly! Details: &quot;', $annotationText, '&quot;')"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </note>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </item>       
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