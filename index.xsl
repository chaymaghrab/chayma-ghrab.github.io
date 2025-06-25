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

    <!-- Conteneur principal avec les bonnes classes CSS -->
    <div class="home-container">
      <div class="photo-container">
        <div class="photo" property="schema:image">CG</div>
      </div>
      
      <h1 class="name home-name">
        <span property="schema:givenName foaf:givenName">
          <xsl:value-of select="$current-lang/identite/prenom"/>
        </span> 
        <span property="schema:familyName foaf:familyName">
          <xsl:value-of select="$current-lang/identite/nom"/>
        </span>
      </h1>
      
      <h2 class="title" property="schema:jobTitle">
        <xsl:value-of select="$current-lang/identite/titre"/>
      </h2>
      
      <div class="objective" property="schema:description">
        "<xsl:value-of select="normalize-space($current-lang/identite/objectif)"/>"
      </div>
      
      <div class="buttons">
        <!-- Modification : Ajouter le paramètre de langue à l'URL du CV -->
        <a class="btn btn-primary" property="schema:url">
          <xsl:attribute name="href">
            <xsl:choose>
              <xsl:when test="$lang != 'fr'">cv.html?lang=<xsl:value-of select="$lang"/></xsl:when>
              <xsl:otherwise>cv.html</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="$labels/voir_cv"/>
        </a>
        <a class="btn btn-secondary" property="schema:email">
          <xsl:attribute name="href">mailto:<xsl:value-of select="$current-lang/identite/contact/email"/></xsl:attribute>
          <xsl:value-of select="$labels/contact_moi"/>
        </a>
      </div>
      
      <div class="contact-info" typeof="schema:ContactPoint">
        <div class="contact-item" property="schema:telephone">
          📞 <xsl:value-of select="$current-lang/identite/contact/tel"/>
        </div>
        <div class="contact-item">📧 
          <a property="schema:email">
            <xsl:attribute name="href">mailto:<xsl:value-of select="$current-lang/identite/contact/email"/></xsl:attribute>
            <xsl:value-of select="$current-lang/identite/contact/email"/>
          </a>
        </div>
        <div class="contact-item">
          <span property="schema:addressLocality">
            📍 <xsl:value-of select="$current-lang/identite/contact/ville"/>
          </span>
          <meta property="schema:addressCountry" content="FR" />
        </div>
        <div class="contact-item">💼 
          <a target="_blank" property="schema:sameAs foaf:account">
            <xsl:attribute name="href"><xsl:value-of select="$current-lang/identite/contact/linkedin"/></xsl:attribute>
            LinkedIn
          </a>
        </div>
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>