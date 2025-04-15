if ("serviceWorker" in navigator) {
    window.addEventListener("load", () => {
      navigator.serviceWorker
        .register("./script/sw.js")
        .then((registration) => {
          console.log("Service Worker registered with scope:", registration.scope);
        })
        .catch((error) => {
          console.error("Service Worker registration failed:", error);
        });
    });
}

function display(id){
    var container = document.getElementById("d"+id)
    var imgArrow = document.getElementById("arrow"+id)
    var table = document.querySelectorAll("#table")
    
    if(imgArrow.className.includes("down")){
        container.classList.remove("display")
        container.classList.add("display0")
        imgArrow.classList.remove("down")
        imgArrow.classList.add("up")
        // for(i=0; i< table.length; i++){
        //     table[i].classList.remove("displayTableOn")
        //     table[i].classList.add("displayTableOff")
        // }
    } else {
        container.classList.add("display")
        container.classList.remove("display0")
        imgArrow.classList.add("down")
        imgArrow.classList.remove("up")
        // for(i=0; i< table.length; i++){
        //     table[i].classList.add("displayTableOn")
        //     table[i].classList.remove("displayTableOff")
        // }
    }
}

function change(path){
    var file =  document.getElementsByClassName(path)
    var values = document.querySelector("#"+path)
    console.log(values)
    if(file[0].files.length>6){
        values.value = null;
        alert("Vous avez selectionner plus de 6 photo, veuillez recommencer")
    }
}

function moove(){
    var bleu = document.getElementById("bleu");
    var fantom = document.getElementById("fantom")
    var a = document.getElementById("a")
    var na = document.getElementById("na")
    if(bleu.className.includes("left")){    // Vers Les Audits
        bleu.classList.remove("left")
        bleu.classList.add("right")
        fantom.classList.remove("right")
        fantom.classList.add("left")
        a.classList.add('visible')
        a.classList.remove('invisible')
        na.classList.add('invisible')
        na.classList.remove('visible')
    } else if (bleu.className.includes("right")){   // Vers Nouvelles Audits
        bleu.classList.remove("right")
        bleu.classList.add("left")
        fantom.classList.remove("left")
        fantom.classList.add("right")
        a.classList.remove('visible')
        a.classList.add('invisible')
        na.classList.remove('invisible')
        na.classList.add('visible')
    } else {                                // Vers Les Audits
        bleu.classList.add("right")
        fantom.classList.add("left")
        a.classList.add("visible")
        na.classList.add("invisible")
    }
}

document.addEventListener("DOMContentLoaded", function () {
    let ancienneValeur = document.getElementById("select").value;
    
    document.getElementById("select").addEventListener("change", function () {
        let nouvelleValeur = this.value;
        var oldVal = document.getElementById("d"+ancienneValeur)
        var newVal = document.getElementById("d"+nouvelleValeur)
        oldVal.style.display = "none"
        newVal.style.display = "flex"
        ancienneValeur = nouvelleValeur;
    });
});