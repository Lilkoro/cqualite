<?php

require_once("./sql.php");
require_once("./display.php");
echo '<script src="./script.js"></script>';
$nomClient = $_POST["nomClient"];
$id = explode("#", $nomClient);
$nomClient = $id[0];

// Créer un dossier pour stocker les photos
$date = date("Y-m-d");
$photoDir = "../photo/" . $nomClient . "_" . $date;
if (!is_dir($photoDir)) {
    mkdir($photoDir, 0777, true);
}

// Vérifier si la table existe
$like = $nomClient . "%"; // Utiliser le nom de la table avec un joker
$tableCheck = $conn->query("SHOW TABLES LIKE '$like'");
$a = $tableCheck->fetchAll(); // Récupérer les résultats de la requête
$rowNumbers = $tableCheck->rowCount();
if ($rowNumbers == 0) {
    // Si la table n'existe pas, créer une nouvelle table
    $stmt = $conn->prepare("CALL newAudit(:client)");
    $stmt->bindParam(':client', $nomClient, PDO::PARAM_STR);
    $stmt->execute();
    $validTableName = $nomClient; // Nom de la nouvelle table
} else {
    // Si la table existe, dupliquer la table existante
    $previousTable = $a[$rowNumbers - 1][0];
    $stmt = $conn->prepare("CALL dupliAudit(:name, :previousTable, @fullTableName)");
    $stmt->bindParam(':name', $nomClient, PDO::PARAM_STR);
    $stmt->bindParam(':previousTable', $previousTable, PDO::PARAM_STR);
    $stmt->execute();

    // Récupérer le nom complet de la nouvelle table
    $result = $conn->query("SELECT @fullTableName AS fullTableName");
    $row = $result->fetch(PDO::FETCH_ASSOC);
    $validTableName = $row['fullTableName'];
}

// Remplir le tableau avec les données de la requête POST
foreach ($_POST as $key => $value) {
    if (is_array($value)) {
        foreach ($value as $k => $v) {
            $note = $v;
            $id = $k;
            // Récupérer obsEcart et suggPlanAction en utilisant le bon format de clé
            $obsEcart = $_POST["obsEcart#$id"] ?? null;
            $suggPlanAction = $_POST["suggPlanAction#$id"] ?? null;

            // Gérer les photos associées à la question
            $photoPaths = [];
            if (isset($_FILES["photo#$id"])) {
                $photos = $_FILES["photo#$id"];
                $totalPhotos = count($photos["name"]); // Nombre total de photos
                for ($i = 0; $i < $totalPhotos; $i++) {
                    if ($photos["error"][$i] === UPLOAD_ERR_OK) {
                        $tmpName = $photos["tmp_name"][$i];
                        $extension = pathinfo($photos["name"][$i], PATHINFO_EXTENSION);
                        $fileName = "photo-$id-" . ($i + 1) . "_sur_" . $totalPhotos . "." . $extension; // Nouveau nom de fichier
                        $targetPath = $photoDir . "/" . $fileName;
                        if (move_uploaded_file($tmpName, $targetPath)) {
                            $photoPaths[] = $targetPath;
                        }
                    }
                }
            }

            // Convertir les chemins des photos en une chaîne séparée par des ";"
            $photoPathsString = implode(";", $photoPaths);

            // Insérer ou mettre à jour la table avec les données POST
            $sql = $conn->prepare("UPDATE `$validTableName` SET note = :note, obsEcart = :obsEcart, suggPlanAction = :suggPlanAction, picPath = :picPath WHERE id = :id");
            $sql->execute([
                "note" => $note,
                "obsEcart" => $obsEcart,
                "suggPlanAction" => $suggPlanAction,
                "picPath" => $photoPathsString,
                "id" => $id
            ]);
        }
    }
}

header("Location: ../index.php?success=1&client=$nomClient");
