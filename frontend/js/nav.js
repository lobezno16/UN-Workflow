/* ============================================================================
   NAV.JS — Navigation controller
   Scroll-direction awareness, glassmorphism on scroll, mobile menu
   ============================================================================ */

class Navigation {
  constructor() {
    this.nav = document.getElementById('main-nav');
    this.hamburger = document.getElementById('hamburger');
    this.mobileMenu = document.getElementById('mobile-menu');
    this.lastScrollY = 0;
    this.ticking = false;
    
    if (!this.nav) return;
    this.init();
  }
  
  init() {
    this.bindScroll();
    this.bindHamburger();
    this.bindMobileLinks();
    this.bindSmoothScroll();
  }
  
  bindScroll() {
    window.addEventListener('scroll', () => {
      if (!this.ticking) {
        requestAnimationFrame(() => {
          this.onScroll();
          this.ticking = false;
        });
        this.ticking = true;
      }
    });
  }
  
  onScroll() {
    const scrollY = window.scrollY;
    
    // Add glassmorphism background after scrolling past hero
    if (scrollY > 100) {
      this.nav.classList.add('is-scrolled');
    } else {
      this.nav.classList.remove('is-scrolled');
    }
    
    // Hide nav when scrolling down, show when scrolling up
    if (scrollY > this.lastScrollY && scrollY > 500) {
      this.nav.style.transform = 'translateY(-100%)';
    } else {
      this.nav.style.transform = 'translateY(0)';
    }
    
    this.lastScrollY = scrollY;
  }
  
  bindHamburger() {
    if (!this.hamburger || !this.mobileMenu) return;
    
    this.hamburger.addEventListener('click', () => {
      this.hamburger.classList.toggle('is-open');
      this.mobileMenu.classList.toggle('is-open');
      document.body.style.overflow = this.mobileMenu.classList.contains('is-open') ? 'hidden' : '';
    });
  }
  
  bindMobileLinks() {
    if (!this.mobileMenu) return;
    
    this.mobileMenu.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => {
        this.hamburger.classList.remove('is-open');
        this.mobileMenu.classList.remove('is-open');
        document.body.style.overflow = '';
      });
    });
  }
  
  bindSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', (e) => {
        const targetId = anchor.getAttribute('href').slice(1);
        const target = document.getElementById(targetId);
        
        if (target) {
          e.preventDefault();
          
          // Use Lenis if available, fallback to native
          if (window.lenisInstance) {
            window.lenisInstance.scrollTo(target, {
              offset: -80,
              duration: 1.5,
            });
          } else {
            target.scrollIntoView({ behavior: 'smooth', block: 'start' });
          }
        }
      });
    });
  }
}

// Export for use in app.js
window.Navigation = Navigation;
