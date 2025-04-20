<?php
// Include database configuration
require_once './config/sql.php';
$client = $_POST["nomClient"] ?? null;
if ($client == 0) {
    echo '<script>alert("Nom du client non spécifié.");</script>';
    header("Location: rapport.php");
}
// Fetch questions with both obsEcart and suggPlanAction filled
$query = "SELECT id, indicateur, question, note, obsEcart, suggPlanAction, picPath 
          FROM $client 
          WHERE obsEcart IS NOT NULL 
          AND obsEcart != '' 
          AND suggPlanAction IS NOT NULL 
          AND suggPlanAction != ''
          ORDER BY id";

try {
    $stmt = $conn->prepare($query);
    $stmt->execute();
    $questions = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    die("Query failed: " . $e->getMessage());
}
?>

<!DOCTYPE html>
<html lang="fr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de Contrôle Qualité</title>
    <link rel="stylesheet" href="./style/export.css">
    <!-- For photo lightbox -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/lightbox2@2.11.3/dist/css/lightbox.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <style>
        button {
            padding: 8px 15px;
            background-color: #2c3e50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
    </style>
</head>

<body>
    <div class="container">
        <header>
            <h1>Tableau de Contrôle Qualité</h1>
            <p class="subtitle">Questions avec observations d'écart et plans d'action suggérés</p>
            <button id="download">Télécharger en PDF</button>
        </header>

        <main>
            <?php if (empty($questions)): ?>
                <div class="no-data">
                    <p>Aucune question avec des observations et des plans d'action n'a été trouvée.</p>
                </div>
            <?php else: ?>
                <div class="table-container" id="content" name-data="<?php echo htmlspecialchars($client); ?>">
                    <table>
                        <thead>
                            <tr>
                                <th>Indicateur</th>
                                <th>Question</th>
                                <th>Note</th>
                                <th>Photos</th>
                                <th>Observation d'écart</th>
                                <th>Plan d'action suggéré</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($questions as $question): ?>
                                <tr>
                                    <td class="indicator">
                                        <span class="indicator-badge"><?php echo htmlspecialchars($question['indicateur']); ?></span>
                                    </td>
                                    <td class="question-text"><?php echo htmlspecialchars($question['question']); ?></td>
                                    <td class="note <?php echo getNoteClass($question['note']); ?>">
                                        <?php echo formatNote($question['note']); ?>
                                    </td>
                                    <td class="photos">
                                        <?php displayPhotos($question['picPath']); ?>
                                    </td>
                                    <td class="obs-ecart"><?php echo htmlspecialchars($question['obsEcart']); ?></td>
                                    <td class="sugg-plan"><?php echo htmlspecialchars($question['suggPlanAction']); ?></td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            <?php endif; ?>
        </main>

        <footer>
            <p>&copy; <?php echo date("Y"); ?> Système de Contrôle Qualité</p>
        </footer>
    </div>

    <!-- JavaScript for lightbox -->
    <script src="https://cdn.jsdelivr.net/npm/lightbox2@2.11.3/dist/js/lightbox-plus-jquery.min.js"></script>
    <script src="./script/export.js"></script>
    <script src="script.js"></script>
</body>

</html>

<?php
// Helper functions
function getNoteClass($note)
{
    if ($note === 'NO' || $note == -1) {
        return 'note-negative';
    } elseif ($note == 1) {
        return 'note-positive';
    } else {
        return 'note-neutral';
    }
}

function formatNote($note)
{
    if ($note === null || $note === '') {
        return 'N/A';
    }
    return htmlspecialchars($note);
}

function displayPhotos($picPath)
{
    if (empty($picPath)) {
        echo '<span class="no-photos">Aucune photo</span>';
        return;
    }

    $photos = explode(';', $picPath);
    echo '<div class="photo-grid">';

    $count = 0;
    foreach ($photos as $photo) {
        if ($count >= 6) break; // Maximum of 6 photos

        $photoPath = trim($photo);
        if (!empty($photoPath)) {
            // // Supprimer le premier point uniquement
            $picPath = preg_replace('/\./', '', $photoPath, 1);
            echo '<a href="' . htmlspecialchars($picPath) . '" data-lightbox="question-' . $count . '" class="photo-thumbnail">';
            echo '<img src="' . htmlspecialchars($picPath) . '" alt="Photo">';
            echo '</a>';
            $count++;
        }
    }

    echo '</div>';
}
?>