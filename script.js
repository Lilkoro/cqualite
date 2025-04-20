let isDownloading = false;

document.getElementById('download').addEventListener('click', () => {

    // Récupère l'élément avec l'attribut name-data
    const ele = document.querySelector('[name-data]');
    const nameDataValue = ele.getAttribute('name-data');
    if (isDownloading) return; // Empêche l'exécution si déjà en cours
    console.log('Téléchargement en cours...'); // Indique que le téléchargement est en cours
    isDownloading = true;

    const downloadButton = document.getElementById('download');
    downloadButton.disabled = true; // Désactive le bouton

    const element = document.getElementById('content'); // Sélectionne le contenu à convertir
    const options = {
        margin: 1,
        filename: 'rapport-'+ nameDataValue +'.pdf',
        image: {
            type: 'jpeg',
            quality: 0.98
        },
        html2canvas: {
            scale: 2,
            useCORS: true // Permet de gérer les styles CSS correctement
        },
        jsPDF: {
            unit: 'pt', // Utilisation des points pour une meilleure précision
            format: 'a4', // Format A4 pour gérer plusieurs pages
            orientation: 'portrait'
        }
    };

    // Convertit le contenu en PDF avec gestion multi-pages
    html2pdf().set(options).from(element).toPdf().get('pdf').then((pdf) => {
        const totalPages = pdf.internal.getNumberOfPages();
        for (let i = 1; i <= totalPages; i++) {
            pdf.setPage(i);
            pdf.setFontSize(10);
            // Déplace le texte plus à gauche en réduisant la valeur X
            pdf.text(`Page ${i} sur ${totalPages}`, pdf.internal.pageSize.getWidth() - 60, pdf.internal.pageSize.getHeight() - 10);
        }
    }).save().finally(() => {
        isDownloading = false; // Réinitialise le verrou
        downloadButton.disabled = false; // Réactive le bouton après la fin du téléchargement
    });
});    