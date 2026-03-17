/* ============================================================================
   HERO.JS — Canvas particle system for hero background
   Creates floating golden particles with connecting lines
   ============================================================================ */

class HeroParticles {
  constructor(canvasId) {
    this.canvas = document.getElementById(canvasId);
    if (!this.canvas) return;
    
    this.ctx = this.canvas.getContext('2d');
    this.particles = [];
    this.mouse = { x: null, y: null, radius: 150 };
    this.animationFrame = null;
    this.isActive = true;
    
    this.config = {
      particleCount: 60,
      particleColor: 'rgba(201, 168, 76, ',
      lineColor: 'rgba(201, 168, 76, ',
      maxLineDistance: 180,
      minRadius: 1,
      maxRadius: 2.5,
      speed: 0.3,
    };
    
    this.init();
  }
  
  init() {
    this.resize();
    this.createParticles();
    this.bindEvents();
    this.animate();
  }
  
  resize() {
    this.canvas.width = this.canvas.parentElement.offsetWidth;
    this.canvas.height = this.canvas.parentElement.offsetHeight;
  }
  
  createParticles() {
    this.particles = [];
    const count = window.innerWidth < 768 ? 30 : this.config.particleCount;
    
    for (let i = 0; i < count; i++) {
      this.particles.push({
        x: Math.random() * this.canvas.width,
        y: Math.random() * this.canvas.height,
        vx: (Math.random() - 0.5) * this.config.speed,
        vy: (Math.random() - 0.5) * this.config.speed,
        radius: Math.random() * (this.config.maxRadius - this.config.minRadius) + this.config.minRadius,
        opacity: Math.random() * 0.5 + 0.2,
        pulse: Math.random() * Math.PI * 2,
      });
    }
  }
  
  bindEvents() {
    window.addEventListener('resize', () => {
      this.resize();
      this.createParticles();
    });
    
    this.canvas.addEventListener('mousemove', (e) => {
      const rect = this.canvas.getBoundingClientRect();
      this.mouse.x = e.clientX - rect.left;
      this.mouse.y = e.clientY - rect.top;
    });
    
    this.canvas.addEventListener('mouseleave', () => {
      this.mouse.x = null;
      this.mouse.y = null;
    });
  }
  
  drawParticles() {
    this.particles.forEach((p) => {
      // Pulse effect
      p.pulse += 0.02;
      const pulseOpacity = p.opacity + Math.sin(p.pulse) * 0.15;
      
      this.ctx.beginPath();
      this.ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
      this.ctx.fillStyle = this.config.particleColor + pulseOpacity + ')';
      this.ctx.fill();
      
      // Glow effect
      this.ctx.beginPath();
      this.ctx.arc(p.x, p.y, p.radius * 3, 0, Math.PI * 2);
      this.ctx.fillStyle = this.config.particleColor + (pulseOpacity * 0.1) + ')';
      this.ctx.fill();
    });
  }
  
  drawLines() {
    for (let i = 0; i < this.particles.length; i++) {
      for (let j = i + 1; j < this.particles.length; j++) {
        const dx = this.particles[i].x - this.particles[j].x;
        const dy = this.particles[i].y - this.particles[j].y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        
        if (distance < this.config.maxLineDistance) {
          const opacity = (1 - distance / this.config.maxLineDistance) * 0.15;
          this.ctx.beginPath();
          this.ctx.moveTo(this.particles[i].x, this.particles[i].y);
          this.ctx.lineTo(this.particles[j].x, this.particles[j].y);
          this.ctx.strokeStyle = this.config.lineColor + opacity + ')';
          this.ctx.lineWidth = 0.5;
          this.ctx.stroke();
        }
      }
    }
  }
  
  updateParticles() {
    this.particles.forEach((p) => {
      // Mouse interaction
      if (this.mouse.x !== null && this.mouse.y !== null) {
        const dx = this.mouse.x - p.x;
        const dy = this.mouse.y - p.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        
        if (distance < this.mouse.radius) {
          const force = (this.mouse.radius - distance) / this.mouse.radius;
          p.vx -= (dx / distance) * force * 0.02;
          p.vy -= (dy / distance) * force * 0.02;
        }
      }
      
      // Update position
      p.x += p.vx;
      p.y += p.vy;
      
      // Dampen velocity
      p.vx *= 0.999;
      p.vy *= 0.999;
      
      // Wrap around edges
      if (p.x < 0) p.x = this.canvas.width;
      if (p.x > this.canvas.width) p.x = 0;
      if (p.y < 0) p.y = this.canvas.height;
      if (p.y > this.canvas.height) p.y = 0;
    });
  }
  
  animate() {
    if (!this.isActive) return;
    
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    this.drawLines();
    this.drawParticles();
    this.updateParticles();
    
    this.animationFrame = requestAnimationFrame(() => this.animate());
  }
  
  destroy() {
    this.isActive = false;
    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame);
    }
  }
}

// Initialize when DOM is ready
let heroParticles;
document.addEventListener('DOMContentLoaded', () => {
  heroParticles = new HeroParticles('hero-canvas');
});
