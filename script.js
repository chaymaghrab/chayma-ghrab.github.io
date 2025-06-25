
/**
 * Récupère le paramètre de langue de l'URL
 * @returns {string} 'fr', 'en', ou 'zh' (par défaut: 'fr')
 */
function getLangFromURL() {
    const params = new URLSearchParams(window.location.search);
    return params.get('lang') || 'fr';
}

/**
 * Change la langue en mettant à jour le paramètre d'URL
 * @param {string} lang - Code langue ('fr', 'en', 'zh')
 */
function changeLang(lang) {
    const currentURL = new URL(window.location.href);
    currentURL.searchParams.set('lang', lang);
    window.location.href = currentURL.toString();
}

/**
 * Récupère la langue actuelle via l'API PHP
 * @returns {Promise<string>} Code de langue
 */
async function getCurrentLang() {
    try {
        const response = await fetch('lang_handler.php?api=current_lang');
        const data = await response.json();
        return data.lang || 'fr';
    } catch (error) {
        console.error('Erreur lors de la récupération de la langue:', error);
        // Fallback vers l'ancienne méthode
        return getLangFromURL();
    }
}

/**
 * Génère une URL avec la langue actuelle conservée
 * @param {string} baseUrl - URL de base (ex: 'cv.html', 'index.html')
 * @returns {string} URL avec paramètre de langue si nécessaire
 */
function generateUrlWithLang(baseUrl) {
    const currentLang = getLangFromURL();
    if (currentLang !== 'fr') {
        const separator = baseUrl.includes('?') ? '&' : '?';
        return `${baseUrl}${separator}lang=${currentLang}`;
    }
    return baseUrl;
}

/**
 * Met à jour tous les liens de navigation pour conserver la langue
 */
function updateNavigationLinks() {
    // Mettre à jour les liens vers le CV
    document.querySelectorAll('a[href="cv.html"]').forEach(link => {
        link.href = generateUrlWithLang('cv.html');
    });
    
    // Mettre à jour les liens vers l'accueil
    document.querySelectorAll('a[href="index.html"]').forEach(link => {
        link.href = generateUrlWithLang('index.html');
    });
    
    // Mettre à jour les liens relatifs
    document.querySelectorAll('a[href^="./"], a[href^="../"]').forEach(link => {
        const originalHref = link.getAttribute('href');
        if (originalHref.includes('.html')) {
            link.href = generateUrlWithLang(originalHref);
        }
    });
}

/**
 * Charge et applique une feuille de style XSL sur un document XML
 * @param {string} xslFile - Chemin vers le fichier XSL
 * @param {Document} xml - Document XML à transformer
 */
function loadXSL(xslFile, xml) {
    fetch(xslFile)
        .then(response => response.text())
        .then(xslText => {
            const parser = new DOMParser();
            const xsl = parser.parseFromString(xslText, "application/xml");
            
            if (xsl) {
                const processor = new XSLTProcessor();
                processor.importStylesheet(xsl);
                const lang = getLangFromURL();
                processor.setParameter(null, 'lang', lang);
                const resultDocument = processor.transformToFragment(xml, document);
                const cvContent = document.getElementById("cv-content");
                cvContent.innerHTML = '';
                cvContent.appendChild(resultDocument);
                
                // Initialiser la navigation après le chargement du contenu
                initializeNavigation();
                // Mettre à jour les liens après le chargement
                updateNavigationLinks();
            } else {
                console.error(`Failed to parse XSL file: ${xslFile}`);
                displayError("Erreur lors du chargement du fichier XSL.");
            }
        })
        .catch(error => {
            console.error(`Failed to fetch XSL file: ${error}`);
            displayError("Erreur lors du chargement du fichier XSL.");
        });
}

/**
 * Affiche un message d'erreur dans le conteneur CV
 * @param {string} message - Message d'erreur à afficher
 */
function displayError(message) {
    const cvContent = document.getElementById("cv-content");
    if (cvContent) {
        cvContent.innerHTML = `<div class="cv-section"><p style="color: #e74c3c; text-align: center;">${message}</p></div>`;
    }
}

/**
 * Initialise la navigation fluide pour les ancres
 */
function initializeNavigation() {
    // Smooth scrolling pour la navigation
    document.querySelectorAll('.nav a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

/**
 * Charge le portfolio XML et applique la transformation XSL
 */
function loadPortfolio() {
    fetch("portfolio.xml")
        .then(response => response.text())
        .then(xmlText => {
            const parser = new DOMParser();
            const xml = parser.parseFromString(xmlText, "application/xml");
            
            // Vérifier s'il y a des erreurs de parsing
            const parseError = xml.querySelector("parsererror");
            if (parseError) {
                throw new Error("Erreur de parsing XML: " + parseError.textContent);
            }
            
            loadXSL("portfolio.xsl", xml);
        })
        .catch(error => {
            console.error(`Failed to fetch XML file: ${error}`);
            displayError("Erreur lors du chargement du fichier XML.");
        });
}

/**
 * Charge le contenu de la page d'accueil depuis le XML
 */
function loadIndexContent() {
    console.log("Début du chargement du contenu index...");
    fetch("portfolio.xml")
        .then(response => {
            console.log("Réponse XML reçue:", response.status);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.text();
        })
        .then(xmlText => {
            console.log("XML récupéré, taille:", xmlText.length);
            const parser = new DOMParser();
            const xml = parser.parseFromString(xmlText, "application/xml");
            
            const parseError = xml.querySelector("parsererror");
            if (parseError) {
                throw new Error("Erreur de parsing XML: " + parseError.textContent);
            }
            
            console.log("XML parsé avec succès");
            // Charger le XSL pour la page d'accueil
            loadIndexXSL("index.xsl", xml);
        })
        .catch(error => {
            console.error('Erreur lors du chargement XML:', error);
            displayIndexError("Erreur lors du chargement du contenu: " + error.message);
        });
}

/**
 * Charge et applique la feuille de style XSL pour la page d'accueil
 */
function loadIndexXSL(xslFile, xml) {
    console.log("Début du chargement XSL:", xslFile);
    fetch(xslFile)
        .then(response => {
            console.log("Réponse XSL reçue:", response.status);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.text();
        })
        .then(xslText => {
            console.log("XSL récupéré, taille:", xslText.length);
            const parser = new DOMParser();
            const xsl = parser.parseFromString(xslText, "application/xml");
            
            const parseError = xsl.querySelector("parsererror");
            if (parseError) {
                throw new Error("Erreur de parsing XSL: " + parseError.textContent);
            }
            
            console.log("XSL parsé avec succès");
            
            if (xsl) {
                const processor = new XSLTProcessor();
                processor.importStylesheet(xsl);
                const lang = getLangFromURL();
                console.log("Langue utilisée:", lang);
                processor.setParameter(null, 'lang', lang);
                
                const resultDocument = processor.transformToFragment(xml, document);
                const indexContent = document.getElementById("index-content");
                
                if (indexContent) {
                    console.log("Transformation réussie, insertion du contenu");
                    indexContent.innerHTML = '';
                    indexContent.appendChild(resultDocument);
                    
                    // Vérifier si le contenu a été inséré
                    console.log("Contenu inséré, éléments trouvés:", indexContent.children.length);
                    
                    // Initialiser les animations après le chargement
                    setTimeout(() => {
                        initializeHomeAnimations();
                        initializeInteractions();
                    }, 100);
                } else {
                    console.error("Element #index-content non trouvé");
                    displayIndexError("Erreur: conteneur non trouvé");
                }
            }
        })
        .catch(error => {
            console.error(`Erreur lors du chargement XSL: ${error}`);
            displayIndexError("Erreur lors du chargement du fichier XSL: " + error.message);
        });
}


/**
 * Validation des formulaires de contact
 */
function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

/**
 * Gestion des interactions utilisateur
 */
function initializeInteractions() {
    // Animation de la photo de profil
    const photo = document.querySelector('.photo');
    if (photo) {
        photo.addEventListener('mouseenter', function() {
            this.style.transform = 'scale(1.1) rotate(5deg)';
        });
        
        photo.addEventListener('mouseleave', function() {
            this.style.transform = 'scale(1) rotate(0deg)';
        });
    }
    
    // Effet de typing pour le titre (optionnel)
    const nameElement = document.querySelector('.home-name');
    if (nameElement) {
        const originalText = nameElement.textContent;
        nameElement.textContent = '';
        
        let i = 0;
        const typeInterval = setInterval(() => {
            if (i < originalText.length) {
                nameElement.textContent += originalText.charAt(i);
                i++;
            } else {
                clearInterval(typeInterval);
            }
        }, 100);
    }
}

/**
 * Gestion du scroll pour la navigation sticky
 */
function initializeScrollEffects() {
    let lastScroll = 0;
    const nav = document.querySelector('.nav');
    
    if (nav) {
        window.addEventListener('scroll', () => {
            const currentScroll = window.pageYOffset;
            
            if (currentScroll > lastScroll && currentScroll > 100) {
                // Scroll vers le bas - cacher la nav
                nav.style.transform = 'translateY(-100%)';
            } else {
                // Scroll vers le haut - montrer la nav
                nav.style.transform = 'translateY(0)';
            }
            
            lastScroll = currentScroll;
        });
    }
}

function displayIndexError(message) {
    const indexContent = document.getElementById("index-content");
    if (indexContent) {
        indexContent.innerHTML = `<div class="error-message" style="color: #e74c3c; text-align: center; padding: 2rem;">${message}</div>`;
    }
}

/**
 * Animations d'entrée pour les éléments de la page d'accueil
 */
function initializeHomeAnimations() {
    const elements = document.querySelectorAll('.photo-container, .name, .title, .objective, .buttons, .contact-info');
    
    elements.forEach((element, index) => {
        if (element) {
            element.style.opacity = '0';
            element.style.transform = 'translateY(30px)';
            element.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
            
            setTimeout(() => {
                element.style.opacity = '1';
                element.style.transform = 'translateY(0)';
            }, index * 200);
        }
    });
}

/**
 * Initialisation des événements au chargement du DOM
 */
document.addEventListener("DOMContentLoaded", function() {
    console.log("DOM chargé, initialisation...");
    
    // Vérifier si on est sur la page d'accueil
    const indexContent = document.getElementById("index-content");
    const cvContent = document.getElementById("cv-content");
    
    if (indexContent) {
        // Page d'accueil
        console.log("Initialisation de la page d'accueil");
        loadIndexContent();
    } else if (cvContent) {
        // Page CV
        console.log("Initialisation de la page CV");
        loadPortfolio();
        initializeScrollEffects();
    }
    
    // Initialisation commune
    initializeCommonFeatures();
});

/**
 * Fonctionnalités communes aux deux pages
 */
function initializeCommonFeatures() {
    // Gestion des erreurs JavaScript globales
    window.addEventListener('error', function(e) {
        console.error('Erreur JavaScript:', e.error);
    });
    
    // Amélioration de l'accessibilité
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Tab') {
            document.body.classList.add('keyboard-navigation');
        }
    });
    
    document.addEventListener('click', function() {
        document.body.classList.remove('keyboard-navigation');
    });
    
    // Performance: Lazy loading des images si nécessaire
    if ('IntersectionObserver' in window) {
        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    if (img.dataset.src) {
                        img.src = img.dataset.src;
                        img.classList.remove('lazy');
                        observer.unobserve(img);
                    }
                }
            });
        });
        
        document.querySelectorAll('img[data-src]').forEach(img => {
            imageObserver.observe(img);
        });
    }
}

// ===== FONCTIONS UTILITAIRES SUPPLÉMENTAIRES =====

/**
 * Debounce function pour optimiser les performances
 */
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

/**
 * Fonction pour détecter si l'utilisateur préfère le mode sombre
 */
function detectDarkMode() {
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
        document.body.classList.add('dark-mode');
    }
}

// Initialiser la détection du mode sombre
detectDarkMode();