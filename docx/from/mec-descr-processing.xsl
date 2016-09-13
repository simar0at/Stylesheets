<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mec="http://mecmua.priv"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd mec tei"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>Merges and disambiguates entity descriptions as found in mecmua documents 
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>Find an id to reference
            <xd:p>Note: Assumtption is that names are always starting with an Uppercase letter.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="mec:getRefIdPerson" as="xs:string?">
        <xsl:param name="name" as="xs:string+"/>
        <xsl:param name="commentN" as="xs:string"/>
        <xsl:param name="commentXML" as="document-node()?"/>
        <xsl:variable name="cleanName" as="xs:string+" select="mec:getCleanName($name)"/>
        <xsl:variable name="lcName" as="xs:string+" select="mec:getLcName($name)"/>         
        <xsl:variable name="allPossibleMatchingNamesComment"
            select="($tagsDecl//tei:person[tei:persName/text()[1] = ($cleanName, $lcName, $name)]|$tagsDecl//tei:person[tei:persName/tei:addName = ($cleanName, $lcName, $name)])"/>
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
    
    <xd:doc>
        <xd:desc>Lowercases a word or first character of a phrase</xd:desc>
    </xd:doc>
    <xsl:function name="mec:getLcName" as="xs:string+">
        <xsl:param name="name" as="xs:string+"/>
        <xsl:for-each select="$name">
            <xsl:value-of select="concat(lower-case(substring(., 1, 1)), substring(., 2))"/>
        </xsl:for-each>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>replaces a binding dash with a simple dash, replaces annotation markers /[]!?*</xd:desc>
    </xd:doc>
    <xsl:function name="mec:getCleanName" as="xs:string+">
        <xsl:param name="name" as="xs:string+"/>
        <xsl:for-each select="$name">
            <xsl:value-of select="normalize-space(translate(., '‑/[]!?*', '-'))"/>
        </xsl:for-each>        
    </xsl:function>
    
    <xsl:function name="mec:getRefIdPlace" as="xs:string">
        <xsl:param name="name" as="xs:string+"/>
        <xsl:param name="commentN" as="xs:string"/>
        <xsl:param name="commentXML" as="document-node()?"/>
        <xsl:variable name="cleanName" as="xs:string+" select="mec:getCleanName($name)"/>
        <xsl:variable name="lcName" as="xs:string+" select="mec:getLcName($name)"/>
        <xsl:variable name="allPossibleMatchingNamesComment" select="($tagsDecl//tei:place[tei:placeName/text()[1] = ($cleanName, $lcName, $name)]|$tagsDecl//tei:place[tei:placeName/tei:addName = ($cleanName, $lcName, $name)])"/>
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
        <xsl:variable name="cleanName" as="xs:string+" select="mec:getCleanName($name)"/>
        <xsl:variable name="lcName" as="xs:string+" select="mec:getLcName($name)"/>
        <xsl:variable name="lcCleanName" as="xs:string+" select="mec:getCleanName(mec:getLcName($name))"/>
        <xsl:variable name="allPossibleMatchingNamesComment" select="($tagsDecl//tei:nym[tei:orth[@xml:lang = 'ota-Latn-t']/text() = ($cleanName, $lcName, $lcCleanName, $name)])"/>
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
    
    
</xsl:stylesheet>