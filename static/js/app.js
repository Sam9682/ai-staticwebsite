// Basic JavaScript for AI-StaticWebsite
document.addEventListener('DOMContentLoaded', function() {
    console.log('AI-StaticWebsite loaded');
    
    // Add click animation to info items
    const infoItems = document.querySelectorAll('.info-item');
    infoItems.forEach(item => {
        item.addEventListener('click', function() {
            this.style.transform = 'scale(0.98)';
            setTimeout(() => {
                this.style.transform = 'scale(1)';
            }, 150);
        });
    });
});