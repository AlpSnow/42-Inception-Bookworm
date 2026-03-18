const allerAvant = document.querySelector(".avant");
const allerApres = document.querySelector(".apres");
const basculer = document.querySelectorAll(".basculer");

let i = 0;

const result = document.querySelector(".result");




function activeSlide(slider) {
    basculer.forEach(s => s.classList.remove("active"));      // on enlève la classe "active" de tous les éléments
    slider.classList.add("active");                           // on ajoute la classe "active" à l'élément concerné
    result.innerHTML = slider.querySelector("img").getAttribute("alt");   // on récupère l'attribut "alt" de l'image pour l'afficher
};




allerApres.addEventListener("click", function () {
    if(i == basculer.length - 1) {                          // si on est sur le dernier alors revenir au premier
        i = 0;
        activeSlide(basculer[i]);
    } else {
        i++;
        activeSlide(basculer[i]);
    }
});

allerAvant.addEventListener("click", function () {
    if(i == 0) {                                           // si on est sur le premier alors revenir au dernier
        i = basculer.length - 1;
        activeSlide(basculer[i]);
    } else {
        i--;
        activeSlide(basculer[i]);
    }
});