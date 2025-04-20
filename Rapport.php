<?php
ob_start(); // Commence la mise en mémoire tampon
require(__DIR__ . "/config/sql.php");
require(__DIR__ . "/config/display.php");
// Database connection parameters
$host = "localhost";
$username = "root";
$password = "";
$database = "cqualite";

// Create database connection
$con = new mysqli($host, $username, $password, $database);

// Check connection
if ($con->connect_error) {
    die("Connection failed: " . $con->connect_error);
}

// Set character set
$con->set_charset("utf8");

// Get audit table name from GET parameter or use default
$auditTable = isset($_GET['enterprise']) ? $_GET['enterprise'] : 'questionaudit';

// Function to get enterprise data
function getEnterprise($name)
{
    require(__DIR__ . "/config/sql.php");
    $name = explode("_", $name)[0];
    $sql = "SELECT * FROM entreprise WHERE Nom = :name";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':name', $name, PDO::PARAM_STR);
    $stmt->execute();
    $result = $stmt->fetchAll();
    if ($result > 0) {
        return $result[0];
    }

    return null;
}

// Function to fetch all themes
function getThemes($con)
{
    $sql = "SELECT id, nomThemeAudit FROM themeaudit WHERE id != 27 ORDER BY id";
    $result = $con->query($sql);

    $themes = [];
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $themes[$row['id']] = $row['nomThemeAudit'];
        }
    }

    return $themes;
}

// Function to fetch questions for a specific theme from a specific audit table
function getQuestions($con, $themeId, $tableName)
{
    // Validate table name to prevent SQL injection
    $validTableName = preg_replace('/[^a-zA-Z0-9_]/', '', $tableName);

    // Check if table exists
    $tableCheck = $con->query("SHOW TABLES LIKE '$validTableName'");
    if ($tableCheck->num_rows == 0) {
        // Table doesn't exist, use default
        $validTableName = 'questionaudit';
    }

    $sql = "SELECT id, indicateur, question, note FROM $validTableName WHERE idTheme = ? ORDER BY id";
    $stmt = $con->prepare($sql);
    $stmt->bind_param("i", $themeId);
    $stmt->execute();
    $result = $stmt->get_result();

    $questions = [];
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $questions[] = $row;
        }
    }

    return $questions;
}

function getAuditDate($nom)
{
    require(__DIR__ . "./config/sql.php");
    $sql = $conn->prepare("SELECT create_time FROM INFORMATION_SCHEMA.TABLES WHERE table_name = :client");
    $sql->execute(['client' => $nom]);
    $temp = $sql->fetch();
    $dateCrea = $temp["create_time"];
    return $dateCrea;
}

// Get all enterprises for dropdown
$historicClient = array();
require(__DIR__ . "./config/sql.php");
$client = "SELECT Nom FROM `entreprise`;";
foreach ($conn->query($client) as $row) {
    $sql = $conn->prepare("show tables like :client ;");
    $sql->execute(['client' => $row["Nom"] . "%"]);
    $info = $sql->fetchAll();
    if ($info) {
        array_push($historicClient, $info);
    }
}

$enterprisesResult = $con->query("SELECT id, Nom FROM entreprise ORDER BY Nom");
$enterprises = [];
while ($row = $enterprisesResult->fetch_assoc()) {
    $enterprises[$row['Nom']] = $row['Nom'];
}

// Get selected enterprise
$selectedEnterpriseName = isset($_GET['enterprise']) ? $_GET['enterprise'] : 0;
$enterpriseData = $selectedEnterpriseName > 0 ? getEnterprise($selectedEnterpriseName) : null;
// Get all themes
$themes = getThemes($con);

// Prepare summary data
$summaryData = [
    'A' => 0,
    'B' => 0,
    'C' => 0,
    'D' => 0,
    'NO' => 0,
    'SO' => 0,
    'blank' => 0,
    'total' => 0
];

// Calculate total items for progress
$totalItems = 0;
foreach ($themes as $themeId => $themeName) {
    $questions = getQuestions($con, $themeId, $auditTable);
    $totalItems += count($questions);
}
?>

<!DOCTYPE html>
<html lang="fr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Audit C-QUALité - <?php echo htmlspecialchars($auditTable); ?></title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            color: #333;
            background-color: #f5f5f5;
        }

        h1 {
            text-align: center;
            margin-bottom: 20px;
            color: #2c3e50;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            border-radius: 5px;
        }

        .audit-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
            flex-wrap: wrap;
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            border-left: 5px solid #2c3e50;
        }

        .audit-header div {
            margin-bottom: 10px;
            min-width: 200px;
        }

        .audit-controls {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 5px;
        }

        .audit-controls form {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            align-items: flex-end;
        }

        .audit-controls select,
        .audit-controls input {
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }

        .audit-controls button {
            padding: 8px 15px;
            background-color: #2c3e50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }

        .audit-controls button:hover {
            background-color: #34495e;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .audit-summary {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .audit-summary-item {
            flex: 1;
            min-width: 150px;
            padding: 15px;
            border-radius: 5px;
            text-align: center;
            color: white;
            font-weight: bold;
        }

        .rating-a-count {
            background-color: #2ecc71;
        }

        .rating-b-count {
            background-color: #f1c40f;
            color: #333;
        }

        .rating-c-count {
            background-color: #e67e22;
        }

        .rating-d-count {
            background-color: #e74c3c;
        }

        .rating-blank-count {
            background-color: #95a5a6;
        }

        .progress-container {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 5px;
        }

        .progress-bar {
            height: 25px;
            background-color: #ecf0f1;
            border-radius: 4px;
            overflow: hidden;
            margin-top: 10px;
        }

        .progress {
            height: 100%;
            background-color: #3498db;
            width: 0%;
            transition: width 0.5s;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
        }

        .audit-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
            font-size: 14px;
        }

        .audit-table th {
            background-color: #2c3e50;
            color: white;
            padding: 10px;
            text-align: left;
            position: sticky;
            top: 0;
        }

        .audit-table td {
            padding: 8px 10px;
            border: 1px solid #ddd;
            vertical-align: top;
        }

        .audit-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .theme-header {
            background-color: #34495e !important;
            color: white;
            padding: 10px;
            font-weight: bold;
            text-align: left;
        }

        .question-row td {
            border-bottom: 1px solid #ddd;
        }

        .indicator {
            width: 60px;
            font-weight: bold;
        }

        .question {
            width: 60%;
        }

        .rating {
            width: 60px;
            text-align: center;
        }

        .rating-a {
            background-color: #2ecc71;
            color: white;
        }

        .rating-b {
            background-color: #f1c40f;
            color: #333;
        }

        .rating-c {
            background-color: #e67e22;
            color: white;
        }

        .rating-d {
            background-color: #e74c3c;
            color: white;
        }

        .legend {
            margin-top: 20px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 5px;
        }

        .legend-item {
            display: flex;
            align-items: center;
            margin-bottom: 5px;
        }

        .legend-color {
            display: inline-block;
            width: 20px;
            height: 20px;
            margin-right: 10px;
            border-radius: 3px;
        }

        @media (max-width: 768px) {
            .audit-table {
                font-size: 12px;
            }

            .audit-table td,
            .audit-table th {
                padding: 5px;
            }

            .indicator {
                width: 40px;
            }

            .question {
                width: auto;
            }

            .audit-controls form {
                flex-direction: column;
                align-items: stretch;
            }
        }

        /* Ajoutez ce style dans votre fichier CSS */
        .avoid-break {
            page-break-inside: avoid;
            break-inside: avoid;
        }

        @media print {
            body {
                padding: 0;
                font-size: 12px;
                background-color: white;
            }

            .container {
                box-shadow: none;
                padding: 0;
            }

            .audit-controls,
            .no-print {
                display: none;
            }

            .audit-table {
                font-size: 11px;
            }

            .theme-header,
            .audit-table th {
                background-color: #ccc !important;
                color: black !important;
            }

            .rating-a,
            .rating-b,
            .rating-c,
            .rating-d {
                color: black !important;
            }

            .rating-a {
                background-color: #cfc !important;
            }

            .rating-b {
                background-color: #ffc !important;
            }

            .rating-c {
                background-color: #fcc !important;
            }

            .rating-d {
                background-color: #faa !important;
            }

            .audit-summary-item {
                border: 1px solid #ddd;
            }

            .rating-a-count {
                background-color: #cfc !important;
                color: black !important;
            }

            .rating-b-count {
                background-color: #ffc !important;
                color: black !important;
            }

            .rating-c-count {
                background-color: #fcc !important;
                color: black !important;
            }

            .rating-d-count {
                background-color: #faa !important;
                color: black !important;
            }

            .rating-blank-count {
                background-color: #eee !important;
                color: black !important;
            }
        }
    </style>
</head>

<body>
    <div class="container">
        <h1 name-data="<?php echo htmlspecialchars($auditTable); ?>">Grille d'audit C-QUALité - <?php echo htmlspecialchars($auditTable); ?></h1>

        <div class="audit-controls no-print">

            <form method="GET" action="">

                <div class="form-group">
                    <label for="enterprise">Établissement :</label>
                    <select name="enterprise" id="enterprise">
                        <option value="0">-- Sélectionner un établissement --</option>
                        <?php foreach ($historicClient as $clients) foreach ($clients as $client): ?>
                            <option value="<?php echo $client[0]; ?>">
                                <?php echo $client[0]; ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <button type="submit">Afficher</button>
            </form>
            <br><br>

            <button id="download">Télécharger en PDF</button>

            <!-- <form method="POST" action="download.php">
                <br><br>
                <button type="submit">Télécharger en PDF</button>
            </form> -->

        </div>
        <div id="content">
            <div class="audit-header">
                <div>
                    <p><strong>Établissement :</strong> <?php echo $enterpriseData ? htmlspecialchars($enterpriseData['Nom']) : '____________________________'; ?></p>
                    <p><strong>Adresse :</strong> <?php echo $enterpriseData ? htmlspecialchars($enterpriseData['Adresse'] . ', ' . $enterpriseData['CPOST'] . ' ' . $enterpriseData['Ville']) : '____________________________'; ?></p>
                </div>
                <div>
                    <p><strong>Date de l'audit :</strong> <?php if (!isset($enterpriseData['Nom'])) {
                                                                echo '____________________________';
                                                            } else {
                                                                echo getAuditDate($enterpriseData['Nom']);
                                                            } ?></p>
                </div>
                <div>
                    <p><strong>Responsable :</strong> <?php echo $enterpriseData ? htmlspecialchars($enterpriseData['Chef de cuisine']) : '____________________________'; ?></p>
                    <p><strong>Téléphone :</strong> <?php echo $enterpriseData ? htmlspecialchars($enterpriseData['Tél']) : '____________________________'; ?></p>
                </div>
            </div>

            <div class="progress-container">
                <h3>Progression de l'audit</h3>
                <div class="progress-bar">
                    <div class="progress" id="progress-bar">0%</div>
                </div>
            </div>

            <div class="audit-summary" id="audit-summary">
                <div class="audit-summary-item rating-a-count">
                    A - Conforme
                    <div id="count-a">0</div>
                </div>
                <div class="audit-summary-item rating-b-count">
                    B - Non-conformité mineure
                    <div id="count-b">0</div>
                </div>
                <div class="audit-summary-item rating-c-count">
                    C - Non-conformité moyenne
                    <div id="count-c">0</div>
                </div>
                <div class="audit-summary-item rating-d-count">
                    D - Non-conformité majeure
                    <div id="count-d">0</div>
                </div>
                <div class="audit-summary-item rating-blank-count">
                    Non évalué
                    <div id="count-blank">0</div>
                </div>
            </div>

            <table class="audit-table">
                <thead class="avoid-break">
                    <tr class="avoid-break">
                        <th class="indicator">Code</th>
                        <th class="question">Question</th>
                        <th class="rating">Note</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    foreach ($themes as $themeId => $themeName):
                        $questions = getQuestions($con, $themeId, $auditTable);
                        // Skip theme if no questions
                        if (empty($questions)) continue;
                    ?>
                        <tr>
                            <td colspan="3" class="theme-header avoid-break"><?php echo htmlspecialchars($themeName); ?></td>
                        </tr>

                        <?php
                        foreach ($questions as $question):
                            // Skip if no indicator or no question
                            if (empty($question['indicateur']) && empty($question['question'])) continue;

                            // Determine rating class
                            $ratingClass = '';
                            if ($question['note'] == '1') {
                                $ratingClass = 'rating-a';
                                $summaryData['A']++;
                            } elseif ($question['note'] == '0') {
                                $ratingClass = 'rating-b';
                                $summaryData['B']++;
                            } elseif ($question['note'] == '-1') {
                                $ratingClass = 'rating-c';
                                $summaryData['C']++;
                            } elseif ($question['note'] == '-2') {
                                $ratingClass = 'rating-d';
                                $summaryData['D']++;
                            } elseif ($question['note'] == 'NO') {
                                $ratingClass = 'rating-blank';
                                $summaryData['NO']++;
                            } elseif ($question['note'] == 'SO') {
                                $ratingClass = 'rating-blank';
                                $summaryData['SO']++;
                            } else {
                                $summaryData['blank']++;
                            }

                            $summaryData['total']++;
                        ?>
                            <tr class="question-row avoid-break">
                                <td class="indicator avoid-break"><?php echo htmlspecialchars($question['indicateur'] ?? ''); ?></td>
                                <td class="question avoid-break"><?php echo htmlspecialchars($question['question'] ?? ''); ?></td>
                                <td class="rating <?php echo $ratingClass; ?> avoid-break"><?php echo htmlspecialchars($question['note'] ?? ''); ?></td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endforeach; ?>
                </tbody>
            </table>

            <div class="legend">
                <h3>Légende :</h3>
                <div class="legend-item">
                    <span class="legend-color" style="background-color: #2ecc71;"></span>
                    A - Conforme
                </div>
                <div class="legend-item">
                    <span class="legend-color" style="background-color: #f1c40f;"></span>
                    B - Non-conformité mineure
                </div>
                <div class="legend-item">
                    <span class="legend-color" style="background-color: #e67e22;"></span>
                    C - Non-conformité moyenne
                </div>
                <div class="legend-item">
                    <span class="legend-color" style="background-color: #e74c3c;"></span>
                    D - Non-conformité majeure
                </div>
                <div class="legend-item">
                    <span class="legend-color" style="background-color: #fff; border: 1px solid #ddd;"></span>
                    Vide - Non évalué ou non applicable
                </div>
            </div>
        </div>
    </div>
    <script src="script.js"></script>
    <script>
        // Update summary counts
        document.getElementById('count-a').textContent = <?php echo $summaryData['A']; ?>;
        document.getElementById('count-b').textContent = <?php echo $summaryData['B']; ?>;
        document.getElementById('count-c').textContent = <?php echo $summaryData['C']; ?>;
        document.getElementById('count-d').textContent = <?php echo $summaryData['D']; ?>;
        document.getElementById('count-no').textContent = <?php echo $summaryData['NO']; ?>;
        document.getElementById('count-so').textContent = <?php echo $summaryData['SO']; ?>;
        document.getElementById('count-blank').textContent = <?php echo $summaryData['blank']; ?>;

        // Calculate completion percentage
        const total = <?php echo $totalItems; ?>;
        const completed = <?php echo $summaryData['A'] + $summaryData['B'] + $summaryData['C'] + $summaryData['D']; ?>;
        const percentage = total > 0 ? Math.round((completed / total) * 100) : 0;

        // Update progress bar
        const progressBar = document.getElementById('progress-bar');
        progressBar.style.width = percentage + '%';
        progressBar.textContent = percentage + '%';

        // Change progress bar color based on completion
        if (percentage < 33) {
            progressBar.style.backgroundColor = '#e74c3c';
        } else if (percentage < 66) {
            progressBar.style.backgroundColor = '#f1c40f';
        } else {
            progressBar.style.backgroundColor = '#2ecc71';
        }
    </script>
</body>

</html>

<?php
// Close connection
$con->close();

// Capture tout le contenu HTML
$pageContent = ob_get_flush();
file_put_contents("temp_content.html", $pageContent); // Sauvegarde dans un fichier temporaire
echo $pageContent; // Affiche la page
?>