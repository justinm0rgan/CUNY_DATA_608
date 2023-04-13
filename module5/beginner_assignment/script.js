// define function to reverse word
const reverseWord = () => {
  let wordValue = document.querySelector(".word").value
  let reversedWord = wordValue.split("").reverse().join("");
  document.querySelector(".reversed").innerHTML = reversedWord
}

// define function to generate multiples
const generateMultiples = () => {
  // get inputted number value and create table
  const numInput = document.querySelector(".number").value

  // create array to store multiples
  const multiples = [];
  for (let i = 1; i <= 20; i++) {
    multiples.push(numInput * i);
  }

const table = document.createElement("table");

// Create a header row for the table
const headerRow = document.createElement("tr");
const headerCell1 = document.createElement("th");
headerCell1.textContent = "Number";
const headerCell2 = document.createElement("th");
headerCell2.textContent = "Multiples";
headerRow.appendChild(headerCell1);
headerRow.appendChild(headerCell2);
table.appendChild(headerRow);

// Populate the table with the multiples
let row;
for (let i = 0; i < multiples.length; i++) {
  if (i % 4 === 0) {
    row = document.createElement("tr");
    const cell1 = document.createElement("td");
    cell1.textContent = numInput;
    const cell2 = document.createElement("td");
    row.appendChild(cell1);
    row.appendChild(cell2);
    table.appendChild(row);
  }
  const cell2 = document.createElement("td");
  cell2.textContent = multiples[i];
  row.appendChild(cell2);
}

// Display the table in the multiplesTable div
const multiplesTable = document.getElementById("multiplesTable");
multiplesTable.appendChild(table);
};