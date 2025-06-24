<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:template match="/portfolio">
        <!-- Section Profil -->
        <div class="cv-section profile-section" id="identite" typeof="schema:Person foaf:Person">
            <xsl:apply-templates select="langue/identite"/>
        </div>
        
        <!-- Section Compétences -->
        <div class="cv-section" id="competences" typeof="schema:SkillSet">
            <h2>Compétences Techniques</h2>
            <xsl:apply-templates select="competences"/>
        </div>
        
        <!-- Section Formation -->
        <div class="cv-section" id="formation" typeof="schema:EducationalOccupationalCredential">
            <h2>Formation</h2>
            <xsl:apply-templates select="formation"/>
        </div>
        
        <!-- Section Expérience -->
        <div class="cv-section" id="experience" typeof="schema:WorkExperience">
            <h2>Expérience Professionnelle</h2>
            <xsl:apply-templates select="experience"/>
        </div>
        
        <!-- Section Langues -->
        <div class="cv-section" id="langues" typeof="schema:LanguageSkill">
            <h2>Langues</h2>
            <xsl:apply-templates select="langue/identite/langues"/>
        </div>
        
        <!-- Section Intérêts -->
        <div class="cv-section" id="interets" typeof="schema:InterestArea">
            <h2>Centres d'Intérêt</h2>
            <xsl:apply-templates select="langue/identite/interets"/>
        </div>
    </xsl:template>
    
    <xsl:template match="identite">
        <div class="name">
            <span property="schema:givenName foaf:givenName"><xsl:value-of select="prenom"/></span> 
            <span property="schema:familyName foaf:familyName"><xsl:value-of select="nom"/></span>
        </div>
        <div class="title" property="schema:jobTitle">
            <xsl:value-of select="titre"/>
        </div>
        <div style="margin: 1.5rem 0; font-size: 1.1rem; color: #555;" property="schema:description foaf:description">
            <xsl:value-of select="profil"/>
        </div>
        
        <div class="contact-grid" typeof="schema:ContactPoint">
            <div class="contact-item">
                <span>📞</span>
                <span property="schema:telephone"><xsl:value-of select="contact/tel"/></span>
            </div>
            <div class="contact-item">
                <span>📧</span>
                <a href="mailto:{contact/email}" property="schema:email"><xsl:value-of select="contact/email"/></a>
            </div>
            <div class="contact-item">
                <span>📍</span>
                <span property="schema:addressLocality"><xsl:value-of select="contact/ville"/></span>
                <meta property="schema:addressCountry" content="FR" />
            </div>
            <div class="contact-item">
                <span>💼</span>
                <a href="{contact/linkedin}" target="_blank" property="schema:sameAs foaf:account">LinkedIn</a>
            </div>
        </div>
        
        <div style="margin-top: 2rem; padding: 1.5rem; background: white; border-radius: 10px; border-left: 4px solid #667eea;" typeof="schema:SeekingJob">
            <h3 style="color: #333; margin-bottom: 0.5rem;">Objectif</h3>
            <p style="color: #555; font-style: italic;" property="schema:description"><xsl:value-of select="objectif"/></p>
        </div>
    </xsl:template>
    
    <xsl:template match="competences">
        <div class="skills-grid">
            <div class="skill-category" typeof="schema:SkillCategory">
                <h3 property="schema:name">Langages de Programmation</h3>
                <div class="skill-tags">
                    <xsl:call-template name="split-skills">
                        <xsl:with-param name="skills" select="langages"/>
                        <xsl:with-param name="skill-type">schema:ProgrammingLanguage</xsl:with-param>
                    </xsl:call-template>
                </div>
            </div>
            <div class="skill-category" typeof="schema:SkillCategory">
                <h3 property="schema:name">Frameworks &amp; Technologies</h3>
                <div class="skill-tags">
                    <xsl:call-template name="split-skills">
                        <xsl:with-param name="skills" select="frameworks"/>
                        <xsl:with-param name="skill-type">schema:SoftwareApplication</xsl:with-param>
                    </xsl:call-template>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template name="split-skills">
        <xsl:param name="skills"/>
        <xsl:param name="skill-type"/>
        <xsl:param name="delimiter" select="', '"/>
        
        <xsl:choose>
            <xsl:when test="contains($skills, $delimiter)">
                <span class="skill-tag" typeof="{$skill-type}" property="schema:name">
                    <xsl:value-of select="substring-before($skills, $delimiter)"/>
                </span>
                <xsl:call-template name="split-skills">
                    <xsl:with-param name="skills" select="substring-after($skills, $delimiter)"/>
                    <xsl:with-param name="skill-type" select="$skill-type"/>
                    <xsl:with-param name="delimiter" select="$delimiter"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <span class="skill-tag" typeof="{$skill-type}" property="schema:name">
                    <xsl:value-of select="$skills"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="formation">
        <xsl:for-each select="etude">
            <xsl:sort select="@annee" order="descending"/>
            <div class="formation-item" typeof="schema:EducationalOccupationalCredential">
                <div class="date" property="schema:dateCreated"><xsl:value-of select="@annee"/></div>
                <h3 property="schema:name"><xsl:value-of select="."/></h3>
                <meta property="schema:credentialCategory" content="degree" />
            </div>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="experience">
        <xsl:for-each select="stage">
            <xsl:sort select="@date" order="descending"/>
            <div class="experience-item" typeof="schema:WorkExperience">
                <div class="date" property="schema:startDate schema:endDate"><xsl:value-of select="@date"/></div>
                <xsl:if test="@entreprise">
                    <div class="company" property="schema:hiringOrganization" typeof="schema:Organization">
                        <span property="schema:name"><xsl:value-of select="@entreprise"/></span>
                    </div>
                </xsl:if>
                <xsl:if test="text()">
                    <p property="schema:description"><xsl:value-of select="."/></p>
                </xsl:if>
                <meta property="schema:jobTitle" content="Stagiaire" />
            </div>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="langues">
        <div class="languages-grid">
            <xsl:for-each select="langueParlee">
                <div class="language-item" typeof="schema:Language">
                    <div class="language-name" property="schema:name"><xsl:value-of select="."/></div>
                    <div class="language-level" property="schema:proficiencyLevel">
                        <xsl:choose>
                            <xsl:when test="@niveau = 'maternelle'">Langue maternelle</xsl:when>
                            <xsl:when test="@niveau = 'C1'">Niveau C1 - Avancé</xsl:when>
                            <xsl:when test="@niveau = 'B2'">Niveau B2 - Intermédiaire</xsl:when>
                            <xsl:when test="@niveau = 'A2'">Niveau A2 - Élémentaire</xsl:when>
                            <xsl:otherwise>Niveau <xsl:value-of select="@niveau"/></xsl:otherwise>
                        </xsl:choose>
                    </div>
                    <meta property="schema:alternateName" content="{@niveau}" />
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>
    
    <xsl:template match="interets">
        <div class="interests">
            <div class="interests-list">
                <xsl:call-template name="split-interests">
                    <xsl:with-param name="interests" select="."/>
                </xsl:call-template>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template name="split-interests">
        <xsl:param name="interests"/>
        <xsl:param name="delimiter" select="', '"/>
        
        <xsl:choose>
            <xsl:when test="contains($interests, $delimiter)">
                <span class="interest-tag" typeof="schema:Thing" property="schema:name">
                    <xsl:value-of select="substring-before($interests, $delimiter)"/>
                </span>
                <xsl:call-template name="split-interests">
                    <xsl:with-param name="interests" select="substring-after($interests, $delimiter)"/>
                    <xsl:with-param name="delimiter" select="$delimiter"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <span class="interest-tag" typeof="schema:Thing" property="schema:name">
                    <xsl:value-of select="$interests"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>