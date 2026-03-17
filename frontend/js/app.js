/* ============================================================================
   APP.JS — Main application entry point
   Initializes Lenis smooth scroll, animation engine, navigation
   ============================================================================ */

document.addEventListener('DOMContentLoaded', () => {
  // ─────────────────────────────────────────────────
  // PRELOADER
  // ─────────────────────────────────────────────────
  const preloader = document.getElementById('preloader');
  
  window.addEventListener('load', () => {
    setTimeout(() => {
      if (preloader) {
        preloader.classList.add('loaded');
        // Remove from DOM after transition
        setTimeout(() => preloader.remove(), 600);
      }
    }, 800);
  });
  
  // ─────────────────────────────────────────────────
  // LENIS SMOOTH SCROLL
  // ─────────────────────────────────────────────────
  let lenis;
  try {
    lenis = new Lenis({
      duration: 1.2,
      easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
      orientation: 'vertical',
      smoothWheel: true,
      wheelMultiplier: 1,
      touchMultiplier: 2,
    });
    
    window.lenisInstance = lenis;
    
    // Connect Lenis to GSAP ScrollTrigger (only if GSAP loaded)
    if (typeof gsap !== 'undefined' && typeof ScrollTrigger !== 'undefined') {
      lenis.on('scroll', ScrollTrigger.update);
      
      gsap.ticker.add((time) => {
        lenis.raf(time * 1000);
      });
      
      gsap.ticker.lagSmoothing(0);
    } else {
      // Fallback: drive Lenis with requestAnimationFrame
      function raf(time) {
        lenis.raf(time);
        requestAnimationFrame(raf);
      }
      requestAnimationFrame(raf);
    }
    
  } catch (e) {
    console.warn('Lenis not loaded, using native scroll');
  }
  
  // ─────────────────────────────────────────────────
  // INIT MODULES
  // ─────────────────────────────────────────────────
  const nav = new Navigation();
  const animations = new AnimationEngine();
  
  // ─────────────────────────────────────────────────
  // GSAP-ENHANCED STAGGER ANIMATIONS (only if GSAP loaded)
  // ─────────────────────────────────────────────────
  if (typeof gsap !== 'undefined' && typeof ScrollTrigger !== 'undefined') {
    // Organ card stagger entrance
    const organCards = document.querySelectorAll('.organ-card');
    if (organCards.length) {
      gsap.from(organCards, {
        y: 80,
        opacity: 0,
        rotateX: -10,
        stagger: 0.1,
        duration: 1,
        ease: 'expo.out',
        scrollTrigger: {
          trigger: '.organs__grid',
          start: 'top 80%',
          toggleActions: 'play none none reverse',
        },
      });
    }
    
    // ICJ case cards stagger
    const icjCards = document.querySelectorAll('.icj-case-card');
    if (icjCards.length) {
      gsap.from(icjCards, {
        x: -40,
        opacity: 0,
        stagger: 0.15,
        duration: 0.8,
        ease: 'expo.out',
        scrollTrigger: {
          trigger: '.icj-spotlight__cases',
          start: 'top 85%',
          toggleActions: 'play none none reverse',
        },
      });
    }
    
    // Footer reveal
    gsap.from('.footer__top > div', {
      y: 30,
      opacity: 0,
      stagger: 0.1,
      duration: 0.8,
      ease: 'expo.out',
      scrollTrigger: {
        trigger: '.site-footer',
        start: 'top 90%',
        toggleActions: 'play none none reverse',
      },
    });
  }

  // ─────────────────────────────────────────────────
  // CUSTOM CURSOR (subtle gold dot on hover)
  // ─────────────────────────────────────────────────
  const cursor = document.createElement('div');
  cursor.style.cssText = `
    position: fixed;
    width: 8px;
    height: 8px;
    background: var(--color-gold);
    border-radius: 50%;
    pointer-events: none;
    z-index: 9999;
    opacity: 0;
    transition: opacity 0.3s, transform 0.15s ease-out;
    mix-blend-mode: difference;
  `;
  document.body.appendChild(cursor);
  
  document.addEventListener('mousemove', (e) => {
    cursor.style.left = e.clientX - 4 + 'px';
    cursor.style.top = e.clientY - 4 + 'px';
  });
  
  // Show cursor on interactive elements
  const interactives = document.querySelectorAll('a, button, .organ-card, .pulse__card, .icj-case-card');
  interactives.forEach(el => {
    el.addEventListener('mouseenter', () => {
      cursor.style.opacity = '1';
      cursor.style.transform = 'scale(3)';
    });
    el.addEventListener('mouseleave', () => {
      cursor.style.opacity = '0';
      cursor.style.transform = 'scale(1)';
    });
  });
  
  console.log('%c🌐 United Nations Workflow System — Frontend Loaded', 
    'background: #0a0e17; color: #c9a84c; padding: 8px 16px; font-size: 14px; font-family: serif;');
});
