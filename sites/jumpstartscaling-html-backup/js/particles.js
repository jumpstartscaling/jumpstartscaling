// Optimized Particle System for Jumpstart Scaling
// Based on Three.js - Defer loading for performance

const canvas = document.getElementById('particles-container');
if (canvas) {
    // Basic Scene Setup
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    const renderer = new THREE.WebGLRenderer({ alpha: true, antialias: false }); // Antialias false = Faster

    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2)); // Cap pixel ratio for mobile
    canvas.appendChild(renderer.domElement);

    // Reduce particle count on mobile for better battery/performance
    const isMobile = window.innerWidth < 768;
    const count = isMobile ? 200 : 700;

    // Create Particles
    const geometry = new THREE.BufferGeometry();
    const positions = new Float32Array(count * 3);

    // Random distribution
    for (let i = 0; i < count * 3; i++) {
        // Spread particles across a wide area but clustered near center
        positions[i] = (Math.random() - 0.5) * 15;
    }

    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));

    // Gold colored particles with transparency
    const material = new THREE.PointsMaterial({
        size: 0.03,
        color: 0xC9A961, // Gold
        transparent: true,
        opacity: 0.6
    });

    const particles = new THREE.Points(geometry, material);
    scene.add(particles);

    // Position camera
    camera.position.z = 3;

    // Animation Loop
    function animate() {
        requestAnimationFrame(animate);

        // Very slow, subtle rotation
        particles.rotation.y += 0.0005;
        particles.rotation.x += 0.0002;

        // Slight gentle wave motion (optional, nice touch)
        // particles.position.y = Math.sin(Date.now() * 0.0005) * 0.1;

        renderer.render(scene, camera);
    }
    animate();

    // Handle Resize
    window.addEventListener('resize', () => {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
    });
}
