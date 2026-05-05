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
  
  // ─────────────────────────────────────────────────
  // DYNAMIC MATTERS INJECTION
  // ─────────────────────────────────────────────────
  const organCode = document.body.dataset.organ;
  if (organCode && organCode !== 'TC') {
    loadOrganMatters(organCode);
  }

  async function loadOrganMatters(organCode) {
    const tbody = document.getElementById('dynamic-matters-tbody');
    const container = document.getElementById('dynamic-matters-container');
    if (!tbody && !container) return;

    try {
      const response = await fetch(`/api/matters?organ=${organCode}`);
      if (!response.ok) return;
      const matters = await response.json();
      
      const activeMatters = matters.filter(m => m.status !== 'RESOLUTION_ISSUANCE' && m.status !== 'REJECTED').slice(0, 5);

      if (tbody) {
        tbody.innerHTML = '';
        if (activeMatters.length === 0) {
          tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 2rem; color: var(--color-text-muted);">No active matters found.</td></tr>';
          return;
        }

        activeMatters.forEach(m => {
          const tr = document.createElement('tr');
          const statusClass = m.status === 'SUBMITTED' ? 'badge--pending' : 
                              m.status === 'IN_VOTING' ? 'badge--active' : 
                              m.status === 'PASSED' ? 'badge--passed' : 'badge--closed';
                              
          const typeClass = 'badge--active';

          let headersHTML = '';
          if (organCode === 'ICJ') {
            headersHTML = `
              <td class="t-mono">${m.matter_number}</td>
              <td>${m.title}</td>
              <td><span class="badge ${typeClass}">${m.matter_type || 'Case'}</span></td>
              <td><span class="badge ${statusClass}">${m.status}</span></td>
              <td>-</td>
            `;
          } else if (organCode === 'SEC') {
             headersHTML = `
              <td class="t-mono">${m.matter_number}</td>
              <td><span class="badge ${typeClass}">${m.matter_type || 'Policy'}</span></td>
              <td>${m.title}</td>
              <td>${m.submitted_by_name || 'Secretariat'}</td>
              <td class="t-mono">${m.submission_date ? m.submission_date.substring(0,10) : '-'}</td>
              <td><span class="badge ${statusClass}">${m.status}</span></td>
            `;
          } else if (organCode === 'SC') {
            headersHTML = `
              <td class="t-mono">${m.matter_number}</td>
              <td>${m.title}</td>
              <td><span style="color: var(--color-gold);">${m.priority}</span></td>
              <td><span class="badge ${statusClass}">${m.status}</span></td>
              <td><span class="badge badge--closed">Binding</span></td>
            `;
          } else {
            headersHTML = `
              <td class="t-mono">${m.matter_number}</td>
              <td>${m.title}</td>
              <td><span class="badge ${typeClass}">${m.matter_type || 'Resolution'}</span></td>
              <td>${m.priority}</td>
              <td><span class="badge ${statusClass}">${m.status}</span></td>
              <td>${m.submitted_by_name || 'Delegate'}</td>
            `;
          }
          tr.innerHTML = headersHTML;
          tbody.appendChild(tr);
        });
      } else if (container) {
        container.innerHTML = '';
        if (activeMatters.length === 0) {
          container.innerHTML = '<div class="glass-card"><p style="text-align:center; color: var(--color-text-muted);">No active matters found.</p></div>';
          return;
        }

        activeMatters.forEach(m => {
          const card = document.createElement('div');
          card.className = 'glass-card reveal';
          card.innerHTML = `
            <div class="t-mono" style="color: var(--color-teal); margin-bottom: 0.5rem;">${m.matter_number}</div>
            <h3 style="font-size: var(--fs-h3); margin-bottom: 0.5rem;">${m.title}</h3>
            <p class="t-secondary" style="margin-bottom: var(--space-sm);">
              ${m.description || ''}
              <br><br>Submitted by ${m.submitted_by_name || 'Delegate'}.
            </p>
            <div class="flex gap-sm" style="flex-wrap: wrap;">
              <span class="badge ${m.status === 'PASSED' ? 'badge--passed' : 'badge--pending'}">${m.status}</span>
              <span class="badge badge--active">${m.priority} Priority</span>
              <span class="badge badge--closed">${m.requires_voting ? 'Requires Voting' : 'No Voting'}</span>
            </div>
          `;
          container.appendChild(card);
        });
        
        if (typeof ScrollTrigger !== 'undefined') ScrollTrigger.refresh();
      }
    } catch (error) {
      console.error('Failed to load organ matters:', error);
    }
  }

  console.log('%c🌐 United Nations Workflow System — Frontend Loaded', 
    'background: #0a0e17; color: #c9a84c; padding: 8px 16px; font-size: 14px; font-family: serif;');
});
