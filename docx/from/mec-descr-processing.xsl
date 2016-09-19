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
        
    <!--<xsl:variable name="missing_info_marker" select="'info_missing'"/>-->
    <!-- will lead to validation failures becaus it generates ref="" -->
    <xsl:variable name="missing_info_marker" select="''"/>
    
    <xd:doc>
        <xd:desc>Find an id to reference for a person using an explicit tagsDecl XML fragment
        </xd:desc>
    </xd:doc>
    <xsl:function name="mec:getRefIdPerson" as="xs:string?">
        <xsl:param name="name" as="xs:string+"/>
        <xsl:param name="commentN" as="xs:string"/>
        <xsl:param name="commentXML" as="node()?"/>
        <xsl:param name="tagsDecl" as="node()+"/>
        <xsl:variable name="cleanName" as="xs:string+" select="mec:getCleanName($name)"/>
        <xsl:variable name="lcName" as="xs:string+" select="mec:getLcName($name)"/>
        <xsl:variable name="occupation" as="xs:string?" select="$commentXML//tei:occupation"/>
        <xsl:variable name="allPossibleMatchingNamesComments"
            select="($tagsDecl//tei:person[mec:trimEntAttr((tei:persName, tei:persName/tei:addName[mec:trimEntAttr(.) != 'n.a.'])) = ($cleanName, $lcName, $name)])"/>
        <xsl:variable name="allPossibleMatchingComments" select="$allPossibleMatchingNamesComments"/>
        <!-- Creates more problems than it solves -->
        <!--        <xsl:variable name="allPossibleMatchingComments"
            select="if (count($allPossibleMatchingNamesComments) &gt; 1 or $occupation = ('n.a.', '')) then $allPossibleMatchingNamesComments else
            ($allPossibleMatchingNamesComments | $tagsDecl//tei:person[mec:trimEntAttr(tei:occupation) = $occupation])"/>-->
        <xsl:variable name="allMatchingNameComments"
            select="$allPossibleMatchingComments[not(contains(.//tei:note[1], 'not annotated'))]"/>
        <xsl:variable name="firstMatchingNamesId" select="$allMatchingNameComments[1]/@xml:id"/>
        <xsl:choose>
            <xsl:when test="empty($allMatchingNameComments)">
                <!-- Error: finds comment for the next unrelated name!! -->
                <!--       select="concat($commentN,'-',($tagsDecl//tei:person[tei:persName/text()[1] = $name]|$tagsDecl//tei:person[tei:persName/tei:addName = $name])[1]/@xml:id)"-->
                <xsl:value-of
                    select="if (empty($allPossibleMatchingComments[1]/@xml:id)) then $missing_info_marker else $allPossibleMatchingComments[1]/@xml:id"
                />
            </xsl:when>
            <xsl:when test="empty($commentXML)">
                <xsl:value-of select="$firstMatchingNamesId"/>
            </xsl:when>
            <xsl:when test="$commentN eq ''">
                <xsl:value-of select="$firstMatchingNamesId"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="preparedCommentXML" as="element()">
                    <xsl:apply-templates select="$commentXML" mode="prepare-comment"/>
                </xsl:variable>
                <xsl:value-of
                    select="string-join(mec:disambiguate($preparedCommentXML, $allMatchingNameComments)/@xml:id, 'error: ')"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
        
    <xd:doc>
        <xd:desc>Removes trailing whitespace only.</xd:desc>
    </xd:doc>
    <xsl:function name="mec:trimEntAttr" as="xs:string*">
        <xsl:param name="nodesToClean" as="node()*"/>
        <xsl:for-each select="$nodesToClean">
            <xsl:variable name="trimmedText" select="replace(string-join(./text(), ''), '\s+$', '')"/>
            <xsl:if test="$trimmedText ne ''">
                <xsl:value-of select="$trimmedText"/>
            </xsl:if>
        </xsl:for-each>      
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Disambiguate by checking a comment against candidates.</xd:desc>
    </xd:doc>
    <xsl:function name="mec:disambiguate" as="element()?">
        <!-- idea search for best candidate not finished: replace 1 exists((tei:occupation, tei:death, tei:floruit)) -->
        <xsl:param name="comment" as="node()+"/>
        <xsl:param name="candidates" as="element()+"/>
        <xsl:variable name="similarityPoints" as="element()*">
            <xsl:for-each select="$candidates">
                <mec:s type="envelop" ref="{./@xml:id}">
                    <xsl:sequence select="mec:similarityPoints(., $comment, position())"/>
                </mec:s>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="mec:disambiguate($comment, $candidates, $similarityPoints)"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Disambiguate by checking a comment against candidates. Comparison results are passed on.</xd:desc>
    </xd:doc>
    <xsl:function name="mec:disambiguate" as="element()?">
        <!-- idea search for best candidate not finished: replace 1 exists((tei:occupation, tei:death, tei:floruit)) -->
        <xsl:param name="comment" as="element()"/>
        <xsl:param name="candidates" as="element()+"/>
        <xsl:param name="similarityPoints" as="element()*"/>
        <xsl:choose>
            <xsl:when test="count($candidates) = 1">      
                <xsl:sequence select="$candidates"/>
            </xsl:when>
            <xsl:when test="count($similarityPoints[2]/*) &gt; count($similarityPoints[1]/*)">
                <xsl:sequence
                    select="mec:disambiguate($comment, remove($candidates, 1), remove($similarityPoints, 1))"
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
        <xd:desc>Compare two generated TEI structures reporting every match using a tag as a point.
            <xd:p>Note: This is not symetric, exchanging comment and candidate may lead to different results.</xd:p>
            <xd:p>Two attributes of an entity match if:
                <xd:ul>
                    <xd:li>They match as strings.</xd:li>
                </xd:ul>
            </xd:p>
            <xd:p>Two attributes of an entity do not match if:
                <xd:ul>
                    <xd:li>The strings don't match.</xd:li>
                    <xd:li>They are both n.a.</xd:li>
                </xd:ul>
            </xd:p>
            <xd:p>
                If an attribute of an entity is empty (or does not exist)
                no match or not match is reported. 
            </xd:p>
            <xd:p>Two person description are similar if:
                <xd:ul>
                    <xd:li>The persName matches the persName or the other some addName of the other description.</xd:li>
                    <xd:li>Some addName matches some persName or addName of the other description.</xd:li>
                </xd:ul>
            </xd:p>
            <xd:p>Two person description are not similar if:
                <xd:ul>
                    <xd:li>The persName does not match the persName or some addName of the other description.</xd:li>
                    <xd:li>Some addName does not match any persName or addName of the other description.</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
        <xd:param name="comment">The comment that should be matched to the candidate.
            <xd:p>Usually the comment has less attributes specified than the candidate.</xd:p>
        </xd:param>
        <xd:param name="candidate">The candidate from a list of pre generated or external entity description.
            <xd:p>Usually the candidate has more attributes specified than the comment.</xd:p>
        </xd:param>
    </xd:doc>
    <xsl:function name="mec:similarityPoints" as="element()*">
        <xsl:param name="candidate" as="element()"/>
        <xsl:param name="comment" as="element()"/>
        <xsl:param name="positionInCandidateSeq" as="xs:integer"/>
        <xsl:variable name="ownID" as="xs:string?" select="$comment//tei:person/@xml:id | $comment//tei:place/@xml:id | $comment//tei:nym/@xml:id"/>
        <!-- See if we already have this name tagged but with another name in the running text -->
        <!-- Here all sorts of mix and match may occur within one type. -->
        <xsl:variable name="candidateNames" select="mec:trimEntAttr($candidate//tei:persName | $candidate//tei:placeName | $candidate//tei:orth | $candidate//tei:addName[mec:trimEntAttr(.) != 'n.a.'])"/>
        <xsl:variable name="commentNames" select="mec:trimEntAttr($comment//tei:persName | $comment//tei:placeName | $comment//tei:orth | $comment//tei:addName[mec:trimEntAttr(.) != 'n.a.'])"/>
        <!--        <xsl:variable name="nameSimilar" as="element()*">
            <xsl:for-each select="$candidateNames">
                <xsl:if test="some $n in $commentNames satisfies $n eq .">
                    <mec:s type="namex">
                        <xsl:value-of select="."/>
                    </mec:s>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>-->
        <!--                <xsl:variable name="nameDissimilar" as="element(mec:d)*">
            <xsl:for-each select="$candidateNames">
            <xsl:if test="not(some $n in $commentNames satisfies $n eq .)">
            <mec:d type="name"/>
            </xsl:if>
            </xsl:for-each>                    
            </xsl:variable>-->
        <xsl:variable name="otherAttributesSimilar" as="element()*">
            <xsl:if test="(mec:trimEntAttr($comment//tei:persName), mec:trimEntAttr($comment//tei:placeName)) = (mec:trimEntAttr($candidate[@xml:id ne $ownID]//tei:persName) , mec:trimEntAttr($candidate[@xml:id ne $ownID]//tei:placeName))">
                <mec:s type="first name"/>
            </xsl:if>                    
            <!-- Matching specific to persons. -->
            <xsl:if test="$comment//tei:occupation = ($candidate//tei:occupation, '')">
                <mec:s type="occupation"/>
            </xsl:if>
            <xsl:if test="$comment//tei:occupation != '' and $candidate//tei:occupation != '' and
                $comment//tei:occupation != $candidate//tei:occupation">
                <mec:d type="occupation"/>
            </xsl:if>
            <xsl:if test="$comment//tei:death = ($candidate//tei:death, '')">
                <mec:s type="death"/>
            </xsl:if>
            <xsl:if test="$comment//tei:death != '' and $candidate//tei:death != '' and
                $comment//tei:death != $candidate//tei:death">
                <mec:d type="death"/>
            </xsl:if>
            <xsl:if test="$comment//tei:floruit/@from-custom = ($candidate//tei:floruit/@from-custom, '')">
                <mec:s type="floruit from"/>
            </xsl:if>
            <xsl:if test="$comment//tei:floruit/@from-custom != '' and $candidate//tei:floruit/@from-custom != '' and
                $comment//tei:floruit/@from-custom != $candidate//tei:floruit/@from-custom">
                <mec:d type="floruit from"/>
            </xsl:if>
            <xsl:if test="$comment//tei:floruit/@to-custom = ($candidate//tei:floruit/@to-custom, '')">
                <mec:s type="floruit to"/>
            </xsl:if>
            <xsl:if test="$comment//tei:floruit/@to-custom != '' and $candidate//tei:floruit/@to-custom != '' and
                $comment//tei:floruit/@to-custom != $candidate//tei:floruit/@to-custom">
                <mec:d type="floruit to"/>
            </xsl:if>
            <!-- Matching specific to places. -->
            <xsl:if test="$comment//tei:country = ($candidate//tei:country, '')">
                <mec:s type="country"/>
            </xsl:if>
            <xsl:if test="$comment//tei:country != '' and $candidate//tei:country != '' and
                $comment//tei:country != $candidate//tei:country">
                <mec:d type="country"/>
            </xsl:if>
            <!-- Matching specific to other things. -->
            <xsl:for-each select="$comment//tei:sense/text()[1]">
                <xsl:if test=". = ($candidate//tei:sense/text()[1], '')">
                    <mec:s type="sense"/>    
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="$comment//tei:sense/text()[1]">
                <xsl:if test=". != '' and not($candidate//tei:sense/text()[1] = '') and
                    not(. = $candidate//tei:sense/text()[1])">
                    <mec:d type="sense"/>    
                </xsl:if>
            </xsl:for-each>
            <xsl:if test="($positionInCandidateSeq eq 1 or
                empty($candidate/@copyOf) or
                $comment/@xml:id ne $candidate/@copyOf) and
                not(contains($comment//tei:note, 'not determinable'))">
                <!-- Check of remarks/notes are part of the comment is contained in the candidate. -->
                <xsl:if test="exists($candidate//tei:note) and exists($comment//tei:note) and
                    contains($candidate//tei:note, $comment//tei:note)">
                    <mec:s type="note"/>
                </xsl:if>        
                <xsl:if test="exists($candidate//tei:note) and exists($comment//tei:note) and
                    $comment//tei:note = ($candidate//tei:note, '')">
                    <mec:s type="note exact"/>
                </xsl:if>
            </xsl:if> 
        </xsl:variable>
        <xsl:if test="count($otherAttributesSimilar/self::mec:s) &gt;= count($otherAttributesSimilar/self::mec:d)">
            <xsl:sequence select="($otherAttributesSimilar/self::mec:s)"/>
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
    
    <xd:doc>
        <xd:desc>Find an id to reference for a place using an explicit tagsDecl XML fragment
        </xd:desc>
    </xd:doc>
    <xsl:function name="mec:getRefIdPlace" as="xs:string">
        <xsl:param name="name" as="xs:string+"/>
        <xsl:param name="commentN" as="xs:string"/>
        <xsl:param name="commentXML" as="node()?"/>
        <xsl:param name="tagsDecl" as="node()+"/>
        <xsl:variable name="cleanName" as="xs:string+" select="mec:getCleanName($name)"/>
        <xsl:variable name="lcName" as="xs:string+" select="mec:getLcName($name)"/>
        <xsl:variable name="allPossibleMatchingNamesComment" select="($tagsDecl//tei:place[replace(tei:placeName/text()[1], '\s+$', '') = ($cleanName, $lcName, $name)]|$tagsDecl//tei:place[tei:placeName/tei:addName = ($cleanName, $lcName, $name)])"/>
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
                <xsl:variable name="preparedCommentXML" as="element()">
                    <xsl:apply-templates select="$commentXML" mode="prepare-comment"/>
                </xsl:variable>
                <xsl:value-of
                    select="string-join(mec:disambiguate($preparedCommentXML, $allMatchingNamesComment)/@xml:id, 'error: ')"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <xd:doc>
        <xd:desc>Find an id to reference for one of the other named entities using an explicit tagsDecl XML fragment
        </xd:desc>
    </xd:doc>    
    <xsl:function name="mec:getRefIdOtherNames" as="xs:string">
        <xsl:param name="name" as="xs:string+"/>
        <xsl:param name="commentN" as="xs:string"/>
        <xsl:param name="commentXML" as="node()?"/>
        <xsl:param name="tagsDecl" as="node()+"/>
        <xsl:variable name="cleanName" as="xs:string+" select="mec:getCleanName($name)"/>
        <xsl:variable name="lcName" as="xs:string+" select="mec:getLcName($name)"/>
        <xsl:variable name="lcCleanName" as="xs:string+" select="mec:getCleanName(mec:getLcName($name))"/>
        <xsl:variable name="allPossibleMatchingNamesComment" select="($tagsDecl//tei:nym[some $t in tei:orth[@xml:lang = 'ota-Latn-t']/text() satisfies replace($t, '\s+$', '') = ($cleanName, $lcName, $lcCleanName, $name)])"/>
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
                <xsl:variable name="preparedCommentXML" as="element()">
                    <xsl:apply-templates select="$commentXML" mode="prepare-comment"/>
                </xsl:variable>
                <xsl:value-of
                    select="string-join(mec:disambiguate($preparedCommentXML, $allMatchingNamesComment)/@xml:id, 'error: ')"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>    
    
</xsl:stylesheet>