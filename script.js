// ===== FONCTIONS UTILITAIRES =====

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
                const resultDocument = processor.transformToFragment(xml, document);
                const cvContent = document.getElementById("cv-content");
                cvContent.innerHTML = '';
                cvContent.appendChild(resultDocument);
                
                // Initialiser la navigation après le chargement du contenu
                initializeNavigation();
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
 * Animations d'entrée pour les éléments de la page d'accueil
 */
function initializeHomeAnimations() {
    const elements = document.querySelectorAll('.photo-container, .home-name, .home-title, .home-objective, .home-buttons, .home-contact-info');
    
    elements.forEach((element, index) => {
        element.style.opacity = '0';
        element.style.transform = 'translateY(30px)';
        element.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        
        setTimeout(() => {
            element.style.opacity = '1';
            element.style.transform = 'translateY(0)';
        }, index * 200);
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

/**
 * Initialisation des événements au chargement du DOM
 */
document.addEventListener("DOMContentLoaded", function() {
    // Déterminer quelle page est chargée
    const isHomePage = document.body.classList.contains('home-body') || document.querySelector('.home-container');
    const isCVPage = document.body.classList.contains('cv-body') || document.getElementById('cv-content');
    
    if (isHomePage) {
        // Initialisation de la page d'accueil
        console.log("Initialisation de la page d'accueil");
        initializeHomeAnimations();
        initializeInteractions();
        
        // Ajouter des listeners pour les boutons
        const contactBtn = document.querySelector('.btn-secondary');
        if (contactBtn && contactBtn.href.includes('mailto:')) {
            contactBtn.addEventListener('click', function(e) {
                // Optionnel : tracking des clics
                console.log("Contact button clicked");
            });
        }
        
    } else if (isCVPage) {
        // Initialisation de la page CV
        console.log("Initialisation de la page CV");
        loadPortfolio();
        initializeScrollEffects();
        
        // Ajouter un listener pour le bouton retour
        const backBtn = document.querySelector('.back-btn');
        if (backBtn) {
            backBtn.addEventListener('click', function(e) {
                console.log("Back button clicked");
            });
        }
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