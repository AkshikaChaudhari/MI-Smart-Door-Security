const { spawnSync } = require("child_process");

const vvpPath =
    "C:\\Users\\Akshika Chaudhari\\Downloads\\iverilog\\bin\\vvp.exe";

const result = spawnSync(
    vvpPath,
    [
        "simulation/api_test.out",
        "+PIN=9999",
        "+RFID=A1B2C3D4"
    ],
    {
        cwd: "C:\\Users\\Akshika Chaudhari\\Downloads\\Study\\ASSIGNMENT\\5th Sem\\MI",
        encoding: "utf8"
    }
);

console.log("ERROR:");
console.log(result.error);

console.log("EXIT CODE:");
console.log(result.status);

console.log("OUTPUT:");
console.log(result.stdout);

console.log("STDERR:");
console.log(result.stderr);