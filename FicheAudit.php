<?php
    if(!empty($_POST["audit"])){
    }
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="./style/style.css">
    <link rel="stylesheet" href="./style/newAudit.css">    
    <link rel="icon" type="image/x-icon" href="./img/ico.png">
    <title>FicheEntreprise</title>
</head>
<body>    
    <div class="header">
        <img src="img/header.png" alt="header" class="imgc">
    </div>
    <div class="tete">
        <button class="btn" onclick="history.back()">Retour</button>
        <h1 class="titre">Audit pour : <?php echo $_POST["audit"];?> </h1>
    </div>
</body>
</html>