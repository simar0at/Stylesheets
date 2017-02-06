<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mec="http://mecmua.priv"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="urn:local"   
    xmlns:t="urn:generate-common-tagsDecl-unify:test-data"
    exclude-result-prefixes="xs xd mec tei local"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>Code that unifies two annotations for an entity
        </xd:desc>
    </xd:doc>
    
<!--    <xsl:include href="mec-descr-processing.xsl"/>-->
    
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
       
    <xsl:function name="local:gen-group-key" as="xs:string">
        <xsl:param name="c"/>
        <xsl:value-of select="concat($c/tei:occupation, $c/tei:death, $c/*/@from-custom, $c/*/@to-custom,
            $c/@type, $c/tei:placeName[@xml:lang='en-UK'], $c/tei:location/tei:country,
            string-join($c/tei:cit/tei:sense, ''))"/>
    </xsl:function>
    
    <xsl:template match="tei:person|tei:place|tei:item" mode="unify-prepare">
        <xsl:param name="group-key" select="''"/>
        <xsl:param name="whole-group" select="()"/>
        <xsl:variable name="this" select="."/>
        <xsl:variable name="names">
            <xsl:for-each-group select="$whole-group//(tei:persName|tei:placeName|tei:name)" group-by="concat(., @xml:lang)">
                <xsl:copy-of select="."/>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$group-key">                
                <xsl:element name="{local-name()}" namespace="{namespace-uri()}">
                    <xsl:attribute name="group-key">
                        <xsl:value-of select="$group-key"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="(@*, $names , * except tei:persName|tei:placeName|tei:name |text()|processing-instruction()|comment())" mode="#current"/>        
                </xsl:element>
                <xsl:for-each select="$whole-group except .">
                    <xsl:element name="{local-name()}" namespace="{namespace-uri()}">
                        <xsl:attribute name="group-key">
                            <xsl:value-of select="$group-key"/>
                        </xsl:attribute>
                        <xsl:sequence select="@*|(tei:persName|tei:placeName|tei:name)[1]|* except tei:persName|tei:placeName|tei:name"/>
                        <note xmlns="http://www.tei-c.org/ns/1.0">not annotated annotation moved</note>
                    </xsl:element>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$whole-group"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <t:testData>
        <t:case type="unify">
            <t:in>
                <t:indexListsDoc>tests/mec-descr-processing/tagsDecl-Bsp.xml</t:indexListsDoc>
                <t:copyUsed>false</t:copyUsed>
            </t:in>
            <t:expected></t:expected>
        </t:case>    
    </t:testData>
    
    <xsl:template match="tei:listPerson|tei:listPlace|tei:list" mode="unify">
        <xsl:param name="indexLists" tunnel="yes"/>
        <xsl:variable name="prepared" as="element()">
            <xsl:element name="{local-name()}" namespace="{namespace-uri()}">
            <xsl:call-template name="unify-prepare">
                <xsl:with-param name="c" select="tei:person|tei:place|tei:item"/>
            </xsl:call-template>
            </xsl:element>
        </xsl:variable>
        <xsl:apply-templates mode="unify">
            <xsl:with-param name="indexLists" select="$prepared" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>

    <xd:doc>
        <xd:desc>The person is checked against the second list of persons.
            If copyUsed is true then everything is copied
            (what do I need this for then? Is this the point to merge information found in the current document?)
            If copyUsed is false all similar persons are skipped. </xd:desc>
    </xd:doc>
    <xsl:template match="tei:person|tei:place|tei:item" mode="unify">
        <xsl:param name="group-key" select="''"/>
        <xsl:param name="copyUsed" select="true()" tunnel="yes" as="xs:boolean"/>
        <xsl:param name="indexLists" required="yes" tunnel="yes" as="element()"/>
        <xsl:variable name="existingUnifiedRefId">
            <xsl:choose>
                <xsl:when test=". instance of element(tei:person)">
                    <xsl:value-of select="mec:getRefIdPerson(mec:trimEntAttr((tei:persName[not(mec:trimEntAttr(.) = 'n.a.')])), '???', ., $indexLists)"/>
                </xsl:when>
                <xsl:when test=". instance of element(tei:place)">
                    <xsl:value-of select="mec:getRefIdPlace(mec:trimEntAttr((tei:placeName[not(mec:trimEntAttr(.) = 'n.a.')])), '???', ., $indexLists)"/>
                </xsl:when>
                <xsl:when test=". instance of element(tei:item)">
                    <xsl:value-of select="mec:getRefIdOtherNames(mec:trimEntAttr(tei:name[not(mec:trimEntAttr(.) = 'n.a.')]), '???', ., $indexLists)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="externalDecl" select="$indexLists//*[@xml:id = $existingUnifiedRefId]"/>
        <xsl:variable name="group-key" select="$indexLists//*[@xml:id = $existingUnifiedRefId]/@group-key"/>
        <xsl:variable name="externalIsLocal" select="local:createUniID(/, @xml:id) eq data($externalDecl/@xml:id)[1]"/>
        <xsl:copy>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="$existingUnifiedRefId"/>
            </xsl:attribute>
            <xsl:attribute name="copyOf">
                <xsl:value-of select="data(@xml:id)"/>
            </xsl:attribute>
            <xsl:attribute name="group-key">
                <xsl:value-of select="data($group-key)"/>
            </xsl:attribute>
            <xsl:apply-templates select="(@* except (@xml:id|@copyOf))|*|text()|processing-instruction()|comment()" mode="unify">
                <xsl:with-param name="externalDecl" select="if ($externalIsLocal) then () else $externalDecl" tunnel="yes"/>
            </xsl:apply-templates>            
        </xsl:copy>        
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>Removes trailing whitespace only.</xd:desc>
    </xd:doc>
    <xsl:function name="mec:trimEntAttr" as="xs:string*">
        <xsl:param name="nodesToClean" as="element()*"/>
        <xsl:for-each select="($nodesToClean|$nodesToClean//*)">
            <xsl:variable name="trimmedText" select="replace(string-join(./text(), ''), '\s+$', '')"/>
            <xsl:if test="$trimmedText ne ''">
                <xsl:value-of select="$trimmedText"/>
            </xsl:if>
        </xsl:for-each>      
    </xsl:function>
    <xsl:template match="tei:persName[position() = last()]|tei:placeName[position() = last()]" mode="unify">
        <xsl:param name="externalDecl" tunnel="yes"/>
        <xsl:variable name="ret" as="element()*">
            <xsl:if test="exists($externalDecl)">           
                <xsl:variable name="this" select="."/>
                <xsl:variable name="thisName" select="QName(namespace-uri(.),  local-name(.))"/>
                <xsl:variable name="thisTexts" select="mec:trimEntAttr($this/../*[QName(namespace-uri(),  local-name()) eq $thisName])"/>
                <xsl:variable name="externalData" select="$externalDecl//*[QName(namespace-uri(),  local-name()) eq $thisName and not(mec:trimEntAttr(.) = $thisTexts) and @xml:lang eq 'ota-Latn-t']"/>
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
                <xsl:copy>
                    <xsl:apply-templates mode="unify"/>
                    <xsl:apply-templates mode="unify" select="$externalData[not(mec:trimEntAttr(.) = $thisTexts)]/*"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Copy anything else in unify mode.</xd:desc>
    </xd:doc>
    <xsl:template match="@*|*|processing-instruction()|comment()" mode="unify unify-prepare">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="local:createUniID">
        <xsl:param name="doc" as="document-node()"/>
        <xsl:param name="idInDocument" as="xs:string"/>
        <xsl:variable name="documentName" as="xs:string" select="replace(document-uri($doc), '([^/]+/)+(.*)\.xml$', '$2')"/>
        <xsl:variable name="documentNameDecoded" as="xs:string" select="local:pct-decode($documentName)"/>
        <xsl:value-of select="concat('uni_', $documentNameDecoded ,'_', $idInDocument)"/>
    </xsl:function>
    
    <xsl:template match="t:testData">
        <xsl:apply-templates select="t:case"/>   
    </xsl:template>
    
    <xsl:template match="t:setup"/>
    
    <xsl:template match="t:case[@type='unify']">
        <xsl:variable name="indexLists" select="doc(t:in/t:indexListsDoc)/*"/>
<!--        <xsl:variable name="actual">-->
            <xsl:apply-templates select="$indexLists" mode="unify">
                <xsl:with-param name="indexLists" select="$indexLists" tunnel="yes"/>
                <xsl:with-param name="copyUsed" select="t:in/t:copyUsed" tunnel="yes"/>
            </xsl:apply-templates>
<!--        </xsl:variable>
        <xsl:if test="t:expected ne $actual">
            <div type="case">
                <xsl:sequence select="(data(t:in/t:comment/*/@xml:id), $actual)"/>
            </div>
        </xsl:if>-->
    </xsl:template>
   
    <xsl:template match="xsl:stylesheet">
        <div type="testResults">
            <xsl:apply-templates select="t:*"/>
        </div>
    </xsl:template>
    
</xsl:stylesheet>