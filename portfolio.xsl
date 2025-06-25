<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:schema="https://schema.org/"
  xmlns:foaf="http://xmlns.com/foaf/0.1/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="xsl schema foaf dc">

  <xsl:param name="lang" select="'fr'"/>

  <xsl:template match="/portfolio">
    <xsl:variable name="current-lang" select="langue[@code=$lang]"/>
    <xsl:variable name="labels" select="$current-lang/labels"/>
    <xsl:variable name="identite" select="$current-lang/identite"/>

    <!-- Header -->
    <div class="header">
      <h1><xsl:value-of select="$labels/cv_titre"/></h1>
      <p>
        <span property="schema:name">
          <xsl:value-of select="$identite/prenom"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$identite/nom"/>
        </span>
        <xsl:text> - </xsl:text>
        <span property="schema:jobTitle">
          <xsl:value-of select="$identite/titre"/>
        </span>
      </p>
    </div>

    <!-- Navigation -->
    <div class="nav">
      <div class="nav-container">
        <a href="#identite"><xsl:value-of select="$labels/profil"/></a>
        <a href="#competences"><xsl:value-of select="$labels/competences"/></a>
        <a href="#formation"><xsl:value-of select="$labels/formation"/></a>
        <a href="#experience"><xsl:value-of select="$labels/experience"/></a>
        <a href="#langues"><xsl:value-of select="$labels/langues"/></a>
        <a href="#interets"><xsl:value-of select="$labels/interets"/></a>
        <div class="language-switch">
          <button onclick="changeLang('fr')">🇫🇷 Français</button>
          <button onclick="changeLang('en')">🇬🇧 English</button>
          <button onclick="changeLang('zh')">🇨🇳 中文</button>
        </div>
      </div>
    </div>

    <!-- Bouton retour -->
    <a href="index.html" class="back-btn">
      <xsl:value-of select="$labels/retour"/>
    </a>

    <!-- Section Profil -->
    <div class="cv-section profile-section" id="identite" typeof="schema:Person foaf:Person" resource="#me">
      <xsl:apply-templates select="$current-lang/identite">
        <xsl:with-param name="labels" select="$labels"/>
      </xsl:apply-templates>
    </div>

    <!-- Section Compétences -->
    <div class="cv-section" id="competences">
      <h2><xsl:value-of select="$labels/competences"/></h2>
      <div typeof="schema:ItemList">
        <xsl:apply-templates select="competences"/>
      </div>
    </div>

    <!-- Section Formation -->
    <div class="cv-section" id="formation">
      <h2><xsl:value-of select="$labels/formation"/></h2>
      <div typeof="schema:ItemList">
        <xsl:apply-templates select="formation">
          <xsl:with-param name="lang" select="$lang"/>
        </xsl:apply-templates>
      </div>
    </div>

    <!-- Section Expérience -->
    <div class="cv-section" id="experience">
      <h2><xsl:value-of select="$labels/experience"/></h2>
      <div typeof="schema:ItemList">
        <xsl:apply-templates select="experience">
          <xsl:with-param name="lang" select="$lang"/>
        </xsl:apply-templates>
      </div>
    </div>

    <!-- Section Langues -->
    <div class="cv-section" id="langues">
      <h2><xsl:value-of select="$labels/langues"/></h2>
      <div typeof="schema:ItemList">
        <xsl:apply-templates select="$current-lang/identite/langues">
          <xsl:with-param name="current-lang" select="$current-lang"/>
        </xsl:apply-templates>
      </div>
    </div>

    <!-- Section Intérêts -->
    <div class="cv-section" id="interets">
      <h2><xsl:value-of select="$labels/interets"/></h2>
      <div typeof="schema:ItemList">
        <xsl:apply-templates select="$current-lang/identite/interets"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="identite">
    <xsl:param name="labels"/>
    <div class="name">
      <span property="schema:givenName foaf:firstName"><xsl:value-of select="prenom"/></span>
      <span property="schema:familyName foaf:lastName"><xsl:value-of select="nom"/></span>
    </div>
    <div class="title" property="schema:jobTitle dc:title">
      <xsl:value-of select="titre"/>
    </div>
    <div style="margin: 1.5rem 0; font-size: 1.1rem; color: #555;" property="schema:description dc:description">
      <xsl:value-of select="profil"/>
    </div>

    <div class="contact-grid">
      <div class="contact-item" typeof="schema:ContactPoint">
        <span>📞</span>
        <span property="schema:telephone foaf:phone"><xsl:value-of select="contact/tel"/></span>
      </div>
      <div class="contact-item" typeof="schema:ContactPoint">
        <span>📧</span>
        <a href="mailto:{contact/email}" property="schema:email foaf:mbox">
          <xsl:value-of select="contact/email"/>
        </a>
      </div>
      <div class="contact-item" typeof="schema:PostalAddress">
        <span>📍</span>
        <span property="schema:addressLocality foaf:based_near"><xsl:value-of select="contact/ville"/></span>
        <meta property="schema:addressCountry" content="FR" />
      </div>
      <div class="contact-item">
        <span>💼</span>
        <a href="{contact/linkedin}" target="_blank" property="schema:sameAs foaf:account">LinkedIn</a>
      </div>
    </div>

    <div style="margin-top: 2rem; padding: 1.5rem; background: white; border-radius: 10px; border-left: 4px solid #667eea;">
      <h3 style="color: #333; margin-bottom: 0.5rem;"><xsl:value-of select="$labels/objectif"/></h3>
      <p style="color: #555; font-style: italic;" property="schema:jobSeeking dc:description">
        <xsl:value-of select="objectif"/>
      </p>
    </div>
  </xsl:template>

  <xsl:template match="competences">
    <div class="skills-grid" typeof="schema:ItemList">
      <!-- Langages de programmation -->
      <div class="skill-category">
        <h3 property="schema:name dc:title">
          <xsl:choose>
            <xsl:when test="$lang='en'">Programming Languages</xsl:when>
            <xsl:when test="$lang='zh'">编程语言</xsl:when>
            <xsl:otherwise>Langages de Programmation</xsl:otherwise>
          </xsl:choose>
        </h3>
        <div class="skill-tags" property="schema:itemListElement">
          <xsl:call-template name="split-skills">
            <xsl:with-param name="skills" select="langages"/>
            <xsl:with-param name="skill-type">schema:ProgrammingLanguage</xsl:with-param>
          </xsl:call-template>
        </div>
      </div>

      <!-- Frameworks & Technologies -->
      <div class="skill-category">
        <h3 property="schema:name dc:title">
          <xsl:choose>
            <xsl:when test="$lang='en'">Frameworks &amp; Technologies</xsl:when>
            <xsl:when test="$lang='zh'">框架和技术</xsl:when>
            <xsl:otherwise>Frameworks &amp; Technologies</xsl:otherwise>
          </xsl:choose>
        </h3>
        <div class="skill-tags" property="schema:itemListElement">
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
        <span class="skill-tag" typeof="schema:ListItem {$skill-type}" property="schema:item">
          <span property="schema:name dc:title"><xsl:value-of select="normalize-space(substring-before($skills, $delimiter))"/></span>
        </span>
        <xsl:call-template name="split-skills">
          <xsl:with-param name="skills" select="substring-after($skills, $delimiter)"/>
          <xsl:with-param name="skill-type" select="$skill-type"/>
          <xsl:with-param name="delimiter" select="$delimiter"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <span class="skill-tag" typeof="schema:ListItem {$skill-type}" property="schema:item">
          <span property="schema:name dc:title"><xsl:value-of select="normalize-space($skills)"/></span>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="formation">
    <xsl:param name="lang"/>
    <xsl:for-each select="etude">
      <xsl:sort select="@annee" order="descending"/>
      <div class="formation-item" typeof="schema:EducationalOccupationalCredential">
        <div class="date" property="schema:startDate dc:date"><xsl:value-of select="@annee"/></div>
        <h3 property="schema:name dc:title">
          <xsl:choose>
            <xsl:when test="*[local-name()=$lang]">
              <xsl:value-of select="*[local-name()=$lang]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </h3>
        <meta property="schema:credentialCategory" content="degree" />
      </div>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="experience">
    <xsl:param name="lang"/>
    <xsl:for-each select="stage">
      <xsl:sort select="@date" order="descending"/>
      <div class="experience-item" typeof="schema:WorkExperience">
        <div class="date" property="schema:startDate dc:date"><xsl:value-of select="@date"/></div>
        <xsl:if test="@entreprise">
          <div class="company" property="schema:worksFor" typeof="schema:Organization foaf:Organization">
            <span property="schema:name foaf:name"><xsl:value-of select="@entreprise"/></span>
          </div>
        </xsl:if>
        <xsl:if test="*[local-name()=$lang] or text()">
          <p property="schema:description dc:description">
            <xsl:choose>
              <xsl:when test="*[local-name()=$lang]">
                <xsl:value-of select="*[local-name()=$lang]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </p>
        </xsl:if>
        <meta property="schema:jobTitle dc:title" content="Stagiaire" />
      </div>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="langues">
    <xsl:param name="current-lang"/>
    <div class="languages-grid">
      <xsl:for-each select="langueParlee">
        <div class="language-item" typeof="schema:Language">
          <div class="language-name" property="schema:name dc:title"><xsl:value-of select="."/></div>
          <div class="language-level" property="schema:proficiencyLevel dc:description">
            <xsl:value-of select="$current-lang/niveauxLangue/niveau[@code=current()/@niveau]"/>
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
    <xsl:param name="position" select="1"/>
    
    <xsl:choose>
      <xsl:when test="contains($interests, $delimiter)">
        <span class="interest-tag" typeof="schema:Thing" about="#interest_{$position}">
          <span property="schema:name dc:title">
            <xsl:value-of select="normalize-space(substring-before($interests, $delimiter))"/>
          </span>
        </span>
        <xsl:call-template name="split-interests">
          <xsl:with-param name="interests" select="substring-after($interests, $delimiter)"/>
          <xsl:with-param name="delimiter" select="$delimiter"/>
          <xsl:with-param name="position" select="$position + 1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <span class="interest-tag" typeof="schema:Thing" about="#interest_{$position}">
          <span property="schema:name dc:title">
            <xsl:value-of select="normalize-space($interests)"/>
          </span>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>