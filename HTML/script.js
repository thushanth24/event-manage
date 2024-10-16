let currentSectionIndex = 0;
const sections = document.querySelectorAll('.section');

// Function to show the current section
function showSection(index) {
    sections.forEach((section, i) => {
        section.classList.remove('active'); // Remove active class from all sections
        if (i === index) {
            section.classList.add('active'); // Add active class to the current section
            section.scrollIntoView({ behavior: 'smooth' }); // Smoothly scroll to the section
        }
    });
}

// Function to handle scroll events
function handleScroll(event) {
    // Prevent default scroll behavior
    event.preventDefault();

    // Determine direction of scroll
    if (event.deltaY > 0) {
        // Scroll down
        currentSectionIndex = Math.min(currentSectionIndex + 1, sections.length - 1);
    } else {
        // Scroll up
        currentSectionIndex = Math.max(currentSectionIndex - 1, 0);
    }

    // Show the selected section
    showSection(currentSectionIndex);
}

// Show the first section initially
showSection(currentSectionIndex);

// Listen for wheel scroll events
window.addEventListener('wheel', handleScroll);
