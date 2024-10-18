let currentSection = 0;
const sections = document.querySelectorAll('.section');

// Scroll functionality using mouse wheel
document.addEventListener('wheel', function(event) {
    if (event.deltaY > 0) {
        // Scroll down
        currentSection = Math.min(currentSection + 1, sections.length - 1);
    } else {
        // Scroll up
        currentSection = Math.max(currentSection - 1, 0);
    }
    sections[currentSection].scrollIntoView({ behavior: 'smooth' });
});

// Navbar link smooth scrolling
const navbarLinks = document.querySelectorAll('.navbar a');

navbarLinks.forEach(link => {
    link.addEventListener('click', function(event) {
        const href = this.getAttribute('href');

        // Check if the link points to an external page like "home.html"
        if (href.startsWith("#")) {
            // Prevent default only if it's an anchor link
            event.preventDefault();
            const targetId = href.substring(1);
            const targetSection = document.getElementById(targetId);
            if (targetSection) {
                targetSection.scrollIntoView({ behavior: 'smooth' });
            }
        }
        // If the href doesn't start with a hash, the browser will handle it normally
    });
});

