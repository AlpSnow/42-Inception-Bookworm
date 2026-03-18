function shuffleChildren(parent){
    let children = parent.children
    let i = children.length, k, temp
    while(--i > 0){
        k = Math.floor(Math.random() * (i+1))
        temp = children[k]
        children[k] = children[i]
        parent.appendChild(temp)
    }
}

function showReaction(type, clickedBox){
    clickedBox.classList.add(type)
    if (type !== "success"){
        setTimeout(function(){
            clickedBox.classList.remove(type)
        }, 800)
    }
}

function showTime(timeStarting, timeEnding){
    let difference = timeEnding - timeStarting
    let lapse = new Date(difference)

    let minutesLapse = lapse.getMinutes()
    let secondsLapse = lapse.getSeconds()
    let milisecLapse = lapse.getMilliseconds()

    minutesLapse = minutesLapse < 10 ? "0" + minutesLapse : minutesLapse
    secondsLapse = secondsLapse < 10 ? "0" + secondsLapse : secondsLapse

    if (milisecLapse < 10) {
        milisecLapse = "00" + milisecLapse
    } else if (milisecLapse < 100){
        milisecLapse = "0" + milisecLapse
    }

    document.getElementById("timer").innerHTML = "Timer → " + minutesLapse + " : " + secondsLapse + " : " + milisecLapse
}

let nbSquare = prompt("Avec combien de cases désirez vous jouer", 10)

const box = document.createElement("div")
box.classList.add("box")

const board = document.querySelector("#board")

let nb = 1

for(let i = 1; i <= nbSquare; i++){
    let newbox = box.cloneNode()
    newbox.innerText = i 
    board.appendChild(newbox)

    // newbox.addEventListener("click", function(){
    //     console.log("Boite n°" + i + ", click !")
    //     newbox.classList.add("box-clicked")
    // })

    newbox.addEventListener("click", function(){

        if (i == nb){
            newbox.classList.add("box-clicked")
            shuffleChildren(board)
            shuffleChildren(board)
            // On met un 2eme shuffleChildren(board) car sinon la 1ere case bug et ne tourne pas

            if(nb == board.children.length){
                // alert("VICTOIRE !")
                board.querySelectorAll(".box").forEach(function(box){
                    showReaction("success", box)

                    let timeEnd = new Date()
                    showTime(timeStart, timeEnd)
                })

                const replay = document.createElement("button")
                replay.setAttribute("id", "replay")
                replay.innerHTML = "replay"
                document.body.appendChild(replay)
                // board.appendChild(replay);  Pour que le bouton replay soit un enfant de board au lieu du body

                // appendChild permet d'inclure dans un objet plus large un objet enfant

                // replay.onclick = function()     ou  replay.onclick = ()    Il n'est pas obligatoire d'écrire function
                replay.onclick = () => document.location.reload()
            }
            nb++
        }
        // Si nb est égale au nombre de boites du jeu, c'est que le dernier clic était sur la dernière boite
        // donc -> Victoire du joueur ! (Il ne faut pas incrémenter nb avant !)

        else if (i > nb){
            // alert("Erreur, recommencez !")
            showReaction("error", newbox)
            shuffleChildren(board)
            shuffleChildren(board)
            // On met un 2eme shuffleChildren(board) car sinon la 1ere case bug et ne tourne pas
            nb = 1

            board.querySelectorAll(".box-clicked").forEach(function(validBox){
                validBox.classList.remove("box-clicked")
            // L'idée est, lorsque le jeu doit redémarrer (nous nous plaçons donc dans la partie conditionnelle correspondant),
            // de sélectionner les boites grisées en passant par l'élément board (puisqu'il les contient).
            // La méthode querySelectorALl() récupère un tableau d'éléments, sur lequel nous utilisons la méthode forEach()
            // permettant de passer sur chaque élément, élément qui sera représenté ici par l'argument "validBox".
            })
        }
        // Si le numéro de la boite est supérieur à nb, c'est que le joueur à cliqué sur une boite avec un numéro trop élevée
        // Donc -> game over !

        else {
            // alert("Case déjà cliquée !")
            showReaction("notice", newbox)
        }
        // Dernière possibilité : le joueur a cliqué sur une boite déjà grisée.
        // On l'informe simplement de cela, le jeu ne redémarre pas.
    })
}

shuffleChildren(board)
let timeStart = new Date()
