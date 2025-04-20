<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Télécharger en PDF</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
</head>

<body>
    <div id="content">
        <h1>Ma Page Web</h1>
        <p>Ceci est un exemple de contenu à télécharger en PDF.</p>
    </div>
    <button id="download">Télécharger en PDF</button>

    <script>
        document.getElementById('download').addEventListener('click', () => {
            const element = document.getElementById('content'); // Sélectionne le contenu à convertir
            const options = {
                margin: 1,
                filename: 'page-web.pdf',
                image: {
                    type: 'jpeg',
                    quality: 0.98
                },
                html2canvas: {
                    scale: 2
                },
                jsPDF: {
                    unit: 'in',
                    format: 'letter',
                    orientation: 'portrait'
                }
            };

            // Convertit le contenu en PDF
            html2pdf().set(options).from(element).save();
        });
    </script>
</body>

</html>