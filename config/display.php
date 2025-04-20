<?php
function selectModele()
{
    require(__DIR__ . "/sql.php");
    $sql = "SELECT * FROM `modelaudit`;";
    echo '<select name="modele" id="select" form="form" required>';
    echo '<option value="default">Choisissez un modèle pour l\'Audit</option>';
    foreach ($conn->query($sql) as $row) {
        echo '<option value="' . $row["id"] . '">' . $row["nomModelAudit"] . '</option>';
    }
    echo '</select>';
}

function selectClient()
{
    require(__DIR__ . "/sql.php");
    $sql = "SELECT id, Nom FROM `entreprise`;";
    echo '<select name="client" id="select" form="form" required>';
    echo '<option value="default">Choisissez un Client</option>';
    foreach ($conn->query($sql) as $row) {
        echo '<option value="' . $row["Nom"] . '#' . $row["id"] . '">' . $row["Nom"] . '</option>';
    }
    echo '</select>';
}

function pretty($list)
{
    echo '<pre>';
    print_r($list);
    echo '</pre>';
}

function displayQuestion($idTheme, $nbQuest, $state)
{
    require(__DIR__ . "/sql.php");
    if ($state == "new") {
        $query = $conn->prepare("SELECT * FROM questionaudit WHERE idTheme = :idTheme");
    } else {
        $query = $conn->prepare("SELECT * FROM `$state` WHERE idTheme = :idTheme");
    }
    $query->execute(["idTheme" => $idTheme]);
    $questionTheme = $query->fetchAll(PDO::FETCH_ASSOC);

    foreach ($questionTheme as $question) {
        $check_2 = null;
        $check_1 = null;
        $check0 = null;
        $check1 = null;
        $checkNO = null;
        $checkSO = null;

        switch ($question["note"]) {
            case "-2":
                $check_2 = "checked";
                break;
            case "-1":
                $check_1 = "checked";
                break;
            case "0":
                $check0 = "checked";
                break;
            case "1":
                $check1 = "checked";
                break;
            case "NO":
                $checkNO = "checked";
                break;
            case "SO":
                $checkSO = "checked";
                break;
        }

        echo "<p id='p'>" . $question["id"] . ". " . $question['question'] . "</p><br>";
        echo '<div class="table" id="table">
                <div class="note" data-question-count="' . $nbQuest . '">
                    <div class="textRadio" data-theme-id ="' . $idTheme . '"><input type="radio" name="note[' . $question["id"] . ']" value="SO" ' . $checkSO . '><label for="note1">SO</label></div>
                    <div class="textRadio" data-theme-id ="' . $idTheme . '"><input type="radio" name="note[' . $question["id"] . ']" value="NO" ' . $checkNO . '><label for="note2">NO</label></div>
                    <div class="textRadio" data-theme-id ="' . $idTheme . '"><input type="radio" name="note[' . $question["id"] . ']" value="1" ' . $check1 . '><label for="note3">1</label></div>
                    <div class="textRadio" data-theme-id ="' . $idTheme . '"><input type="radio" name="note[' . $question["id"] . ']" value="0" ' . $check0 . '><label for="note4">0</label></div>
                    <div class="textRadio" data-theme-id ="' . $idTheme . '"><input type="radio" name="note[' . $question["id"] . ']" value="-1" ' . $check_1 . '><label for="note5">-1</label></div>
                    <div class="textRadio" data-theme-id ="' . $idTheme . '"><input type="radio" name="note[' . $question["id"] . ']" value="-2" ' . $check_2 . '><label for="note6">-2</label></div>
                </div>
              </div>';
        echo '<table>
                <tr><td>
                    <textarea name="obsEcart#' . $question["id"] . '" cols="40" rows="5" placeholder="Observation/Ecarts constatés ...">' . $question["obsEcart"] . '</textarea>
                    <textarea name="suggPlanAction#' . $question["id"] . '" cols="40" rows="5" placeholder="Suggestion de plan d\'action par l\'auditeur...">' . $question["suggPlanAction"] . '</textarea>
                </td></tr>
              </table>';
        echo '<label for="photo' . $question["id"] . '" class="btnd">Photo</label>
              <input type="file" id="photo' . $question["id"] . '" class="photo1" name="photo#' . $question["id"] . '[]" accept=".jpg, .jpeg, .png" onchange="change(\'photo' . $question["id"] . '\')" multiple/>';
    }
}
function displayTheme($state = "new")
{

    require(__DIR__ . "/sql.php");
    $completionRate = 0;
    $sql = $conn->prepare("SELECT t.*, COUNT(q.id) AS nbQuest FROM themeaudit t LEFT JOIN questionaudit q ON t.id = q.idTheme WHERE t.id < 14 GROUP BY t.id ORDER BY t.id ASC;");
    $sql->execute();
    $info = $sql->fetchAll(PDO::FETCH_ASSOC);
    foreach ($info as $theme) {
        echo '<div class="background" id="d' . $theme["id"] . '">
        <div class="container" onclick="display(' . $theme["id"] . ')">
        <div class="theme-arrow" id="display"><div class="theme">' . $theme["nomThemeAudit"] . '</div>';
        echo "<div id='completion-rate-" . $theme['id'] . "' class='completion-rate'>$completionRate%</div>";
        echo '<div id="arrow' . $theme["id"] . '" class="arrow"><img src="img/arrowDown.png" alt="fleche"></div></div>
        </div>';
        displayQuestion($theme["id"], $theme['nbQuest'], $state);
        echo "</div>";
    }

    // pretty($info);
}
