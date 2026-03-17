/* ============================================================================
   ANIMATIONS.JS — GSAP-powered animation controllers
   Scroll-triggered reveals, parallax, 3D tilt, mask reveals, counters
   ============================================================================ */

class AnimationEngine {
  constructor() {
    this.scrollTriggers = [];
    
    // ALWAYS run IntersectionObserver for reveal and pulse cards
    // This ensures visibility even if GSAP is blocked by tracking prevention
    this.initIntersectionObserver();
    
    // If GSAP is available, enhance with GSAP animations
    if (typeof gsap !== 'undefined' && typeof ScrollTrigger !== 'undefined') {
      this.init();
    } else {
      console.warn('[AnimationEngine] GSAP not loaded — using CSS-only fallback');
    }
  }
  
  /* ─────────────────────────────────────────────────
     INTERSECTION OBSERVER — runs even without GSAP
     Handles .pulse__card and .reveal elements via native IO
     ───────────────────────────────────────────────── */
  initIntersectionObserver() {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.1 });
    
    // Observe pulse cards
    document.querySelectorAll('.pulse__card').forEach(el => observer.observe(el));
    
    // If GSAP won't load, also observe .reveal elements via IO
    if (typeof gsap === 'undefined' || typeof ScrollTrigger === 'undefined') {
      document.querySelectorAll('.reveal, .reveal-left, .reveal-right, .reveal-scale, .mask-reveal').forEach(el => {
        observer.observe(el);
      });
    }
  }
  
  init() {
    gsap.registerPlugin(ScrollTrigger);
    
    this.initHeroAnimations();
    this.initScrollReveals();
    this.initParallax();
    this.initMaskReveals();
    this.initCounters();
    this.initTiltCards();
    this.initNavScrollSpy();
  }
  
  /* ─────────────────────────────────────────────────
     HERO ENTRANCE ANIMATION
     ───────────────────────────────────────────────── */
  initHeroAnimations() {
    const tl = gsap.timeline({ delay: 0.5 });
    
    // Title lines
    tl.from('#hero-title span', {
      y: 120,
      opacity: 0,
      rotationX: -40,
      stagger: 0.15,
      duration: 1.2,
      ease: 'expo.out',
    })
    .to('#hero-eyebrow', {
      y: 0,
      opacity: 1,
      duration: 0.8,
      ease: 'expo.out',
    }, '-=0.6')
    .to('#hero-subtitle', {
      y: 0,
      opacity: 1,
      duration: 0.8,
      ease: 'expo.out',
    }, '-=0.5')
    .to('#hero-cta', {
      y: 0,
      opacity: 1,
      duration: 0.8,
      ease: 'expo.out',
    }, '-=0.4');
    
    // Hero background parallax on scroll
    gsap.to('.hero__bg-image', {
      y: '30%',
      opacity: 0.1,
      ease: 'none',
      scrollTrigger: {
        trigger: '.hero',
        start: 'top top',
        end: 'bottom top',
        scrub: 1,
      },
    });
    
    // Fade out hero content on scroll
    gsap.to('.hero__content', {
      y: -100,
      opacity: 0,
      ease: 'none',
      scrollTrigger: {
        trigger: '.hero',
        start: '20% top',
        end: '80% top',
        scrub: 1,
      },
    });
    
    // Hide scroll indicator
    gsap.to('#scroll-indicator', {
      opacity: 0,
      scrollTrigger: {
        trigger: '.hero',
        start: '10% top',
        end: '30% top',
        scrub: 1,
      },
    });
  }
  
  /* ─────────────────────────────────────────────────
     SCROLL REVEAL — .reveal, .reveal-left, .reveal-right, .reveal-scale
     ───────────────────────────────────────────────── */
  initScrollReveals() {
    const revealSelectors = ['.reveal', '.reveal-left', '.reveal-right', '.reveal-scale'];
    
    // Animate generic reveal elements (exclude the pulse grid, we'll animate that separately)
    revealSelectors.forEach(selector => {
      document.querySelectorAll(selector).forEach(el => {
        if (el.classList.contains('pulse__card')) return; // Skip pulse cards
        
        ScrollTrigger.create({
          trigger: el,
          start: 'top 85%',
          end: 'bottom 15%',
          onEnter: () => el.classList.add('is-visible'),
          onLeave: () => {},
          onEnterBack: () => el.classList.add('is-visible'),
          onLeaveBack: () => el.classList.remove('is-visible'),
        });
      });
    });
  }
  
  /* ─────────────────────────────────────────────────
     PARALLAX DEPTH LAYERS
     ───────────────────────────────────────────────── */
  initParallax() {
    document.querySelectorAll('[data-parallax]').forEach(el => {
      const speed = parseFloat(el.dataset.parallax) || 0.3;
      
      gsap.to(el, {
        y: () => speed * 100,
        ease: 'none',
        scrollTrigger: {
          trigger: el.closest('.parallax-section') || el,
          start: 'top bottom',
          end: 'bottom top',
          scrub: 1,
        },
      });
    });
    
    // Organs section parallax
    gsap.from('.organs__grid', {
      y: 60,
      ease: 'none',
      scrollTrigger: {
        trigger: '.organs-section',
        start: 'top 80%',
        end: 'top 30%',
        scrub: 1,
      },
    });
    
    // ICJ section parallax
    gsap.from('.icj-spotlight__bg', {
      x: '20%',
      opacity: 0,
      ease: 'none',
      scrollTrigger: {
        trigger: '.icj-spotlight',
        start: 'top 80%',
        end: 'top 30%',
        scrub: 1,
      },
    });
  }
  
  /* ─────────────────────────────────────────────────
     MASK REVEALS
     ───────────────────────────────────────────────── */
  initMaskReveals() {
    document.querySelectorAll('.mask-reveal').forEach(el => {
      ScrollTrigger.create({
        trigger: el,
        start: 'top 80%',
        onEnter: () => el.classList.add('is-visible'),
        onLeaveBack: () => el.classList.remove('is-visible'),
      });
    });
  }
  
  /* ─────────────────────────────────────────────────
     COUNTER ANIMATION
     ───────────────────────────────────────────────── */
  initCounters() {
    document.querySelectorAll('[data-count]').forEach(el => {
      const target = parseInt(el.dataset.count);
      
      ScrollTrigger.create({
        trigger: el,
        start: 'top 85%',
        once: true,
        onEnter: () => {
          gsap.to({ val: 0 }, {
            val: target,
            duration: 2,
            ease: 'expo.out',
            onUpdate: function() {
              el.textContent = Math.round(this.targets()[0].val).toLocaleString();
            },
          });
        },
      });
    });
  }
  
  /* ─────────────────────────────────────────────────
     3D TILT CARDS — Mouse tracking for organ cards
     ───────────────────────────────────────────────── */
  initTiltCards() {
    document.querySelectorAll('[data-tilt]').forEach(card => {
      const maxTilt = 8;
      
      card.addEventListener('mousemove', (e) => {
        const rect = card.getBoundingClientRect();
        const centerX = rect.left + rect.width / 2;
        const centerY = rect.top + rect.height / 2;
        
        const percentX = (e.clientX - centerX) / (rect.width / 2);
        const percentY = (e.clientY - centerY) / (rect.height / 2);
        
        gsap.to(card, {
          rotateY: percentX * maxTilt,
          rotateX: -percentY * maxTilt,
          duration: 0.4,
          ease: 'power2.out',
          transformPerspective: 1200,
        });
      });
      
      card.addEventListener('mouseleave', () => {
        gsap.to(card, {
          rotateY: 0,
          rotateX: 0,
          duration: 0.8,
          ease: 'expo.out',
        });
      });
    });
  }
  
  /* ─────────────────────────────────────────────────
     NAV SCROLL SPY
     ───────────────────────────────────────────────── */
  initNavScrollSpy() {
    const sections = ['pulse', 'organs', 'icj'];
    const navLinks = document.querySelectorAll('.nav__link[data-section]');
    
    sections.forEach(sectionId => {
      const section = document.getElementById(sectionId);
      if (!section) return;
      
      ScrollTrigger.create({
        trigger: section,
        start: 'top 50%',
        end: 'bottom 50%',
        onEnter: () => this.setActiveNav(sectionId, navLinks),
        onEnterBack: () => this.setActiveNav(sectionId, navLinks),
      });
    });
  }
  
  setActiveNav(sectionId, links) {
    links.forEach(link => {
      link.classList.toggle('active', link.dataset.section === sectionId);
    });
  }
  
  /* ─────────────────────────────────────────────────
     REFRESH
     ───────────────────────────────────────────────── */
  refresh() {
    ScrollTrigger.refresh();
  }
}

// Export for use in app.js
window.AnimationEngine = AnimationEngine;
