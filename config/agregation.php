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

if (!str_contains($nomClient, "_")) {
    // Appeler la procédure stockée newAudit
    $stmt = $conn->prepare("CALL newAudit(:client)");
    $stmt->bindParam(':client', $nomClient, PDO::PARAM_STR);
    $stmt->execute();
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
                        $fileName = "photo#$id-" . ($i + 1) . "_sur_" . $totalPhotos . "." . $extension; // Nouveau nom de fichier
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
            $sql = $conn->prepare("UPDATE `$nomClient` SET note = :note, obsEcart = :obsEcart, suggPlanAction = :suggPlanAction, picPath = :picPath WHERE id = :id");
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
