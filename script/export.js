document.addEventListener('DOMContentLoaded', function() {
    // Initialize lightbox
    lightbox.option({
        'resizeDuration': 200,
        'wrapAround': true,
        'albumLabel': "Photo %1 sur %2",
        'fadeDuration': 300,
        'imageFadeDuration': 300
    });

    // Add data-label attributes for responsive design
    const tableRows = document.querySelectorAll('tbody tr');
    
    tableRows.forEach(row => {
        const cells = row.querySelectorAll('td');
        const headers = document.querySelectorAll('thead th');
        
        cells.forEach((cell, index) => {
            if (headers[index]) {
                cell.setAttribute('data-label', headers[index].textContent);
            }
        });
    });
});