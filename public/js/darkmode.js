document.addEventListener('DOMContentLoaded', function() {
  // Check for saved dark mode preference
  const savedTheme = localStorage.getItem('theme');
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  
  // Apply theme based on preference or system setting
  if (savedTheme === 'dark' || (savedTheme === null && prefersDark)) {
    document.body.classList.add('dark-mode');
  }
  
  // Create dark mode toggle button and add to navbar
  const createToggleButton = () => {
    const navbarNavs = document.querySelectorAll('.navbar-nav');
    if (navbarNavs.length === 0) return;
    
    // Add to the last navbar-nav (usually the right-aligned one)
    const navbar = navbarNavs[navbarNavs.length - 1];
    
    const toggleContainer = document.createElement('li');
    toggleContainer.className = 'nav-item';
    
    const toggleButton = document.createElement('button');
    toggleButton.className = 'dark-mode-toggle nav-link';
    toggleButton.setAttribute('aria-label', 'Toggle dark mode');
    toggleButton.innerHTML = document.body.classList.contains('dark-mode') 
      ? '☀️' // sun emoji for light mode
      : '🌙'; // moon emoji for dark mode
      
    toggleButton.addEventListener('click', () => {
      // Toggle dark mode class
      document.body.classList.toggle('dark-mode');
      
      // Update button text
      const isDarkMode = document.body.classList.contains('dark-mode');
      toggleButton.innerHTML = isDarkMode ? '☀️' : '🌙';
      
      // Save preference to localStorage
      localStorage.setItem('theme', isDarkMode ? 'dark' : 'light');
    });
    
    toggleContainer.appendChild(toggleButton);
    navbar.appendChild(toggleContainer);
  };
  
  // Initialize the toggle button
  setTimeout(createToggleButton, 100); // Small delay to ensure DOM is fully loaded
}); 