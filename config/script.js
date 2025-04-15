let completionCounts = {}; 

function updateCompletionRate(themeId, totalQuestions) {
    if (!completionCounts[themeId]) {
        completionCounts[themeId] = new Set();
    } else {
        completionCounts[themeId].clear(); // Clear the previous set to avoid duplicates
    }

    // Limitez la sélection des boutons radio à ceux de la catégorie en cours
    const radios = document.querySelectorAll(`[data-theme-id="${themeId}"] input[name^="note"]`);

    radios.forEach((radio) => {
        if (radio.checked) {
            const questionId = radio.name.match(/\d+/)[0];
            completionCounts[themeId].add(questionId);
        }
    });

    const completed = completionCounts[themeId].size;
    const percentage = Math.round((completed / totalQuestions) * 100);
    document.getElementById(`completion-rate-${themeId}`).innerText = `${percentage}%`;

    console.log(`Theme ID: ${themeId}, Completed: ${completed}, Total: ${totalQuestions}, Percentage: ${percentage}%`);
    console.log(completionCounts);
}

document.addEventListener("DOMContentLoaded", () => {
    const radios = document.querySelectorAll(`input[name^="note"]`);
    radios.forEach((radio) => {
        radio.addEventListener("change", () => {
            const themeId = radio.closest("[data-theme-id]").dataset.themeId; // Assurez-vous que chaque thème a un attribut `data-theme-id`.
            const totalQuestions = radio.closest('div[data-question-count]').getAttribute('data-question-count'); // Ajustez si nécessaire.
            updateCompletionRate(themeId, totalQuestions);
        });
    });
});
