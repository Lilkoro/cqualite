<?php
require("./config/display.php");
require("./config/sql.php"); // Inclure la connexion à la base de données
echo '<script src="config/script.js"></script>';
$previousName = $_POST["previousName"] ?? null;

// Appeler la procédure stockée dupliAudit
$stmt = $conn->prepare("CALL dupliAudit(:name, :previousname, @fullTableName)");
$stmt->bindParam(':name', $previousName, PDO::PARAM_STR);
$stmt->bindParam(':previousname', $previousName, PDO::PARAM_STR);
$stmt->bindParam(':name', $previousName, PDO::PARAM_STR);
$stmt->execute();

// Récupérer la valeur de la variable de sortie
$result = $conn->query("SELECT @fullTableName AS fullTableName");
$row = $result->fetch(PDO::FETCH_ASSOC);
$fullTableName = $row['fullTableName'] ?? null;
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" media="all" href="<?php echo './style/style.css?id=' . time(); ?>" />
    <link rel="stylesheet" type="text/css" media="all" href="<?php echo './style/newAudit.css?id=' . time(); ?>" />
    <link rel="manifest" href="manifest.json">
    <link rel="icon" type="image/x-icon" href="./img/ico.png">
    <script src="script/app.js"></script>
    <title>Accueil</title>
</head>

<body>
    <div class="header">
        <img src="img/header.png" alt="header" class="imgc">
    </div>
    <div class="tete">
        <button class="btn" onclick="history.back()">Retour</button>
        <h1 class="titre">Audit pour : <?php echo @$fullTableName; ?></h1>
    </div>

    <select name="whatTheme" id="select">
        <option value="1">1. Réception des Matières premières</option>
        <option value="2">2. Stockage des Matières Premières </option>
        <option value="3">3. Légumerie et Déboitage</option>
        <option value="4">4. Préparations froides</option>
        <option value="5">5. Préparations chaudes</option>
        <option value="6">6. Distribution</option>
        <option value="7">7. Transport (Uniquement Cuisine Centrale)</option>
        <option value="8">8. Hygiene du personnel</option>
        <option value="9">9. Locaux</option>
        <option value="10">10. Materiels et équipements</option>
        <option value="11">11. Nettoyage & Désinfection</option>
        <option value="12">12. Dechets et nuisibles</option>
        <option value="13">13. Vérification du PMS et Amélioration continue</option>
    </select>

    <form action="./config/agregation.php" method="POST" id="form" enctype="multipart/form-data">
        <input type="text" name="ok" id="ok" value="ok" style="display: none;">
        <input type="text" name="nomClient" id="ok" value="<?php echo @$fullTableName; ?>" style="display: none;">
        <div class="supercontainer">
            <?php displayTheme($fullTableName); ?>
        </div>
    </form>

    <div class="pied">
        <input class="btn" type="submit" form="form" value="Valider" />
    </div>
</body>

</html>