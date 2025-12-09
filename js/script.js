let userScore = 0;
let compScore = 0;

const userScorePara = document.querySelector("#user-score");
const compScorePara = document.querySelector("#comp-score");

const choices = document.querySelectorAll(".choice");
const msg = document.querySelector("#msg");

const genCompChoice = () => {
    const options = ["rock", "paper", "scissors"];
    return options[Math.floor(Math.random() * 3)];;
}

const drawGame = () => {
    console.log("Game Draw");
    msg.innerText = "Game Draw.";
    msg.style.backgroundColor = "#081b31";
}

const showWinner = (userWin, userChoice, compChoice) => {
        if(userWin){
            console.log("You Win!");
            msg.innerText = `You Win! Your ${userChoice} beats ${compChoice}.`;
            msg.style.backgroundColor = "green";
            userScore++;
            userScorePara.innerText = userScore;
        } else{
            console.log("You Lose.");
            msg.innerText = `You Lose, ${compChoice} beats your ${userChoice}.`;
            msg.style.backgroundColor = "red";
            compScore++;
            compScorePara.innerText = compScore;
        }
}



playGame = (userChoice) => {
    console.log("user choice: ", userChoice);
    let compChoice = genCompChoice()
    console.log("comp choice: ", compChoice)
    if(userChoice === compChoice){
        drawGame();
    } else{
        let userWin = true;
        if(userChoice === 'rock'){
            //scissors, paper
            userWin = compChoice === "paper" ? false : true;
        } else if(userChoice = "paper"){
            //rock, scissors
            userWin = compChoice === "scissors" ? false : true;
        } else{
            //userChoice == scissors
            //rock, paper
            userWin = compChoice ==="rock" ? false : true;
        }
        showWinner(userWin, userChoice, compChoice);
    }


}

choices.forEach((choice) => {
    choice.addEventListener("click", () => {
        const userChoice = choice.getAttribute("id");
        playGame(userChoice)
    })
});
