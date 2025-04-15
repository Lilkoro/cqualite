<?php

require_once("./sql.php");
require_once("./display.php");

$nomClient = $_POST["nomClient"];

$client = $_POST["client"];
$id = explode("#", $client);
$client = $id[0];

// Appeler la procédure stockée newAudit
$stmt = $conn->prepare("CALL newAudit(:client)");
$stmt->bindParam(':client', $client, PDO::PARAM_STR);
$stmt->execute();

// Remplir le tableau avec les données de la requête POST
foreach ($_POST as $key => $value) {
    if (is_array($value)) {
        foreach ($value as $k => $v) {
            $note = $v;
            $id = $k;
            echo $id;
            // Récupérer obsEcart et suggPlanAction en utilisant le bon format de clé
            $obsEcart = $_POST["obsEcart#$id"] ?? null;
            $suggPlanAction = $_POST["suggPlanAction#$id"] ?? null;

            // Insérer ou mettre à jour la table avec les données POST
            $sql = $conn->prepare("UPDATE `$nomClient` SET note = :note, obsEcart = :obsEcart, suggPlanAction = :suggPlanAction WHERE id = :id");
            $sql->execute([
                "note" => $note,
                "obsEcart" => $obsEcart,
                "suggPlanAction" => $suggPlanAction,
                "id" => $id
            ]);
        }
    }
}
