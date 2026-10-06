const express = require("express");
const path = require("path");
const { exec, spawnSync } = require("child_process");

const app = express();

app.use(express.json());

app.use(express.static(path.join(__dirname, "../frontend")));


app.post("/api/authenticate", (req, res) => {

    const { pin, rfid } = req.body;

    console.log("Authentication request:");
    console.log("PIN :", pin);
    console.log("RFID:", rfid);


    if (!/^[0-9A-Fa-f]{1,4}$/.test(pin)) {

        return res.status(400).json({
            success: false,
            error: "Invalid PIN"
        });

    }


    if (!/^[0-9A-Fa-f]{8}$/.test(rfid)) {

        return res.status(400).json({
            success: false,
            error: "Invalid RFID"
        });

    }


    const projectRoot = path.join(__dirname, "..");

    const compileCommand =
        `iverilog -g2012 -o simulation/api_test.out rtl/*.sv simulation/api_testbench.sv`;


    exec(
        compileCommand,
        { cwd: projectRoot },

        (compileError, stdout, stderr) => {

            if (compileError) {

                console.error("RTL compilation error:");
                console.error(stderr);

                return res.status(500).json({
                    success: false,
                    error: "RTL compilation failed",
                    details: stderr
                });

            }

            const vvpPath =
                "C:\\Users\\Akshika Chaudhari\\Downloads\\iverilog\\bin\\vvp.exe";


            const args = [
                "simulation/api_test.out",
                "+PIN=" + pin,
                "+RFID=" + rfid
            ];


            console.log("Running VVP...");
            console.log("PIN:", pin);
            console.log("RFID:", rfid);
            console.log("Arguments:", args);


            const result = spawnSync(
                vvpPath,
                args,
                {
                    cwd: projectRoot,
                    encoding: "utf8"
                }
            );


            console.log("VVP output:");
            console.log(result.stdout);


            if (result.error) {

                console.error(result.error);

                return res.status(500).json({
                    success: false,
                    error: "VVP execution failed",
                    details: result.error.message
                });

            }


            if (result.status !== 0) {

                return res.status(500).json({
                    success: false,
                    error: "RTL simulation failed",
                    details: result.stderr
                });

            }


            res.json({
                success: true,
                simulation: result.stdout
            });

        }

    );

});


app.get("/api/status", (req, res) => {

    res.json({
        system: "SecureLock",
        status: "online",
        engine: "SystemVerilog + Icarus Verilog"
    });

});


app.get("/api/test-alarm", (req, res) => {

    console.log("================================");
    console.log("DOOR ALARM TEST REQUEST RECEIVED");
    console.log("================================");


    const projectRoot = path.join(__dirname, "..");


    const compileCommand =
        `iverilog -g2012 -o simulation/alarm_test.out rtl/*.sv simulation/alarm_testbench.sv`;


    exec(
        compileCommand,
        { cwd: projectRoot },

        (compileError, stdout, stderr) => {

            if (compileError) {

                return res.status(500).json({
                    success: false,
                    error: "Alarm RTL compilation failed",
                    details: stderr
                });

            }


            const vvpPath =
                "C:\\Users\\Akshika Chaudhari\\Downloads\\iverilog\\bin\\vvp.exe";


            const result = spawnSync(
                vvpPath,
                ["simulation/alarm_test.out"],
                {
                    cwd: projectRoot,
                    encoding: "utf8"
                }
            );


            if (result.error) {

                return res.status(500).json({
                    success: false,
                    error: "Alarm simulation failed",
                    details: result.error.message
                });

            }


            res.json({
                success: true,
                simulation: result.stdout
            });

        }

    );

});

const PORT = 3000;

app.listen(PORT, () => {

    console.log(
        `SecureLock server running at http://localhost:${PORT}`
    );

});