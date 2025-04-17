<?php
require("./config/display.php");
echo '<script src="config/script.js"></script>';
if (isset($_POST["ok"])) {
    $cheminTemporaire = $_FILES['photo1']['tmp_name'];
    echo $cheminTemporaire;
    // Renommez le fichier en "Menu.jpg"
    $nouveauNomFichier = 'Menu.jpg';
    $cheminDestination = './img' . $nouveauNomFichier;
    // Déplacez le nouveau fichier vers le dossier "Images"
    move_uploaded_file($cheminTemporaire, $cheminDestination);
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" media="all" href="<?php echo './style/style.css?id=' . time(); ?>" />
    <link rel="stylesheet" type="text/css" media="all" href="<?php echo './style/accueil.css?id=' . time(); ?>" />
    <link rel="manifest" href="manifest.json">
    <link rel="icon" type="image/x-icon" href="./img/ico.png">
    <script src="script/app.js"></script>
    <!-- <script src="https://cdn.jsdelivr.net/npm/eruda"></script>
    <script>eruda.init();</script> -->
    <title>Accueil</title>
</head>

<body>
    <div class="header">
        <img src="img/headerGrand.png" alt="header" class="imgc">
    </div>
    <div class="tete">
        <div class="fantom" id="fantom" onclick="moove()"></div>
        <div class="bleu" id="bleu"></div>
        <div class="newAudit"><span id="txtAudit">Nouvel Audit</span><img src="./img/Document.png" alt="" class="logo"></div>
        <div class="audits"><span id="txtAudit">Les Audits</span><img src="./img/Bookmark.png" alt="" class="logo"></div>
    </div>
    <div class="a" id="a">
        <h1>Historique des audits : </h1>
        <div class="filter">
            <input type="date" name="date" id="select">
            <input type="text" name="ref" id="select" placeholder="Réference">
        </div>
        <input type="button" name="btn" id="btn" class="btn audit" value="Rechercher">
        <div class="container">
            <table>
                <thead>
                    <tr>
                        <th scope="col">Nom du Client</th>
                        <th scope="col">Date de l'audit</th>
                        <th scope="col">Etat de l'audit</th>
                    </tr>
                </thead>
                <?php allAudit(); ?>
            </table>
        </div>
    </div>
    <div class="na" id="na">
        <h1>Nouvel Audit : </h1>
        <form action="newAudit.php" method="POST" id="form" enctype="multipart/form-data">
            <?php selectModele(); ?>
            <?php selectClient(); ?>
            <input type="text" name="ref" id="select" placeholder="Réference">
        </form>
        <div class="pied">
            <input class="btn" type="submit" form="form" value="Valider" />
        </div>
    </div>
</body>

</html>