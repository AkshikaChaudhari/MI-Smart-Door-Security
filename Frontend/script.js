let pin = "";
let attempts = 0;
let lockedOut = false;
let doorUnlocked = false;
let doorTimeoutTimer = null;
let doorAlarmActive = false;


const pinDisplay = document.getElementById("pinDisplay");

const submitBtn = document.getElementById("submitBtn");
const clearBtn = document.getElementById("clearBtn");

const lockBtn = document.getElementById("lockBtn");
const unlockBtn = document.getElementById("unlockBtn");

const emergencyBtn = document.getElementById("emergencyBtn");
const clearLogBtn = document.getElementById("clearLog");

const lockIcon = document.getElementById("lockIcon");
const doorStatus = document.getElementById("doorStatus");
const doorMessage = document.getElementById("doorMessage");

const authStatus = document.getElementById("authStatus");
const attemptsDisplay = document.getElementById("attempts");

const rfidStatus = document.getElementById("rfidStatus");
const alarmStatus = document.getElementById("alarmStatus");

const pinAuth = document.getElementById("pinAuth");
const rfidAuth = document.getElementById("rfidAuth");

const sensorStatus = document.getElementById("sensorStatus");
const lockoutStatus = document.getElementById("lockoutStatus");
const emergencyStatus = document.getElementById("emergencyStatus");

const eventLog = document.getElementById("eventLog");


const navItems = document.querySelectorAll(".nav-item");

navItems.forEach(item => {

    item.addEventListener("click", () => {

        navItems.forEach(nav => {
            nav.classList.remove("active");
        });

        item.classList.add("active");

        const section = item.dataset.section;

        if (section === "dashboard") {
            window.scrollTo({
                top: 0,
                behavior: "smooth"
            });
        }
        else if (section === "authentication") {
            const authenticationPanel =
                document.querySelector(".content-grid");

            if (authenticationPanel) {
                authenticationPanel.scrollIntoView({
                    behavior: "smooth",
                    block: "start"
                });
            }
        }
        else if (section === "securityLogs") {
            const logPanel =
                document.querySelector(".log-panel");
            if (logPanel) {
                logPanel.scrollIntoView({
                    behavior: "smooth",
                    block: "start"
                });
            }
        }
    });
});


function addLog(message) {
    if (!eventLog) return;

    const entry = document.createElement("div");

    entry.className = "log-entry";

    const time = document.createElement("span");

    time.className = "log-time";

    time.textContent = new Date().toLocaleTimeString();

    const text = document.createElement("span");

    text.textContent = message;

    entry.appendChild(time);
    entry.appendChild(text);

    eventLog.prepend(entry);
}

function updatePinDisplay() {
    if (!pinDisplay) return;

    if (pin.length === 0) {
        pinDisplay.textContent = "••••";
    }
    else {
        pinDisplay.textContent = "•".repeat(pin.length);
    }
}


document.querySelectorAll("[data-key]").forEach(button => {

    button.addEventListener("click", () => {

        const key = button.dataset.key;

        if (pin.length >= 4) {
            return;
        }

        pin += key;

        updatePinDisplay();

    });

});


if (clearBtn) {

    clearBtn.addEventListener("click", () => {

        pin = "";

        updatePinDisplay();

        if (authStatus)
            authStatus.textContent = "WAITING";

        addLog("PIN entry cleared.");

    });

}

async function authenticateWithRTL(pinValue) {

    if (!pinValue) {
        addLog("Please enter a PIN.");
        return;
    }

    if (!/^[0-9A-Fa-f]{1,4}$/.test(pinValue)) {
        addLog("Invalid PIN format.");
        return;
    }

    if (lockedOut) {
        addLog("SYSTEM LOCKOUT ACTIVE.");
        return;
    }

    addLog("Authentication request sent to RTL.");

    if (authStatus)
        authStatus.textContent = "VERIFYING";

    if (pinAuth)
        pinAuth.textContent = "Checking";

    try {

        const response = await fetch("/api/authenticate", {

            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({
                pin: pinValue,
                rfid: "A1B2C3D4"
            })

        });

        const data = await response.json();

        if (!data.success) {

            addLog("Backend error: " + data.error);

            if (authStatus)
                authStatus.textContent = "ERROR";

            return;
        }

        const simulation = data.simulation;

        console.log("RTL SIMULATION:");
        console.log(simulation);

        const authSuccess =
            /AUTH_SUCCESS=1/.test(simulation);

        const alarm =
            /ALARM=1/.test(simulation);

        const lockout =
            /LOCKOUT=1/.test(simulation);

        const doorUnlock =
            /DOOR_UNLOCK=1/.test(simulation);


        if (lockout) {
            attempts = 3;
            lockedOut = true;
        }
        else if (authSuccess) {
            attempts = 0;
            lockedOut = false;
        }
        else {
            attempts = Math.min(attempts + 1, 3);
            if (attempts >= 3) {
                lockedOut = true;
            }
        }

        if (attemptsDisplay) {
            attemptsDisplay.textContent =
                attempts + " / 3";
        }

        if (authSuccess && doorUnlock) {
            lockedOut = false;
            doorUnlocked = true;

            authStatus.textContent = "GRANTED";

            pinAuth.textContent = "Verified";
            rfidStatus.textContent = "VERIFIED";
            rfidAuth.textContent = "Verified";

            alarmStatus.textContent = "OFF";
            lockoutStatus.textContent = "INACTIVE";

            addLog("ACCESS GRANTED — PIN verified.");
            addLog("RFID verified successfully.");
            addLog("SystemVerilog authentication successful.");

            setUnlocked();
        }
        else if (alarm) {
            authStatus.textContent = "ALARM";
            alarmStatus.textContent = "ON";

            addLog("SECURITY ALARM ACTIVATED.");

            setLocked();
        }
        else {
            authStatus.textContent = "DENIED";

            pinAuth.textContent = "Invalid";
            rfidStatus.textContent = "NOT VERIFIED";
            rfidAuth.textContent = "Pending";

            addLog("ACCESS DENIED — Incorrect PIN.");

            if (attempts >= 3) {

                lockedOut = true;

                lockoutStatus.textContent = "ACTIVE";

                alarmStatus.textContent = "ON";

                addLog("SYSTEM LOCKOUT ACTIVATED.");

            }
            setLocked();
        }

        updateSecurityDisplay();

        pin = "";
        updatePinDisplay();
    }

    catch (error) {
        console.error(error);

        authStatus.textContent = "ERROR";
        addLog(
            "Unable to connect to SecureLock backend."
        );
    }
}

if (submitBtn) {
    submitBtn.addEventListener("click", () => {
        authenticateWithRTL(pin);
    });
}


if (unlockBtn) {
    unlockBtn.addEventListener("click", () => {
        if (doorUnlocked) {
            addLog(
                "Door is already unlocked."
            );
            return;
        }

        addLog( "Authentication required before unlocking.");
    });
}


if (lockBtn) {
    lockBtn.addEventListener("click", () => {
        setLocked();

        addLog(
            "Door manually locked."
        );
    });
}

function setUnlocked() {
    doorUnlocked = true;
    if (lockIcon)
        lockIcon.textContent = "🔓";

    if (doorStatus)
        doorStatus.textContent = "UNLOCKED";

    if (doorMessage)
        doorMessage.textContent =
            "Access granted. Door is unlocked.";

    document.body.classList.add(
        "door-unlocked"
    );

    if (sensorStatus)
        sensorStatus.textContent = "OPEN";

    addLog(
        "Door unlocked."
    );

    addLog(
        "Door-open timer started."
    );

    if (doorTimeoutTimer) {
        clearTimeout(doorTimeoutTimer);
    }

    doorTimeoutTimer = setTimeout(() => {

        triggerDoorAlarm();

    }, 5000);
    }

async function triggerDoorAlarm() {

    if (!doorUnlocked)
        return;

    addLog(
        "Door has remained open beyond timeout."
    );

    addLog(
        "Checking SystemVerilog door-timeout logic..."
    );


    try {

        const response =
            await fetch("/api/test-alarm");

        const data =
            await response.json();


        if (!data.success) {

            addLog(
                "Door alarm simulation failed."
            );

            return;
        }


        const simulation =
            data.simulation;


        console.log(
            "Door timeout RTL:",
            simulation
        );


        const alarmDetected =
            /ALARM\s*=\s*1/.test(simulation);


        const buzzerDetected =
            /BUZZER\s*=\s*1/.test(simulation);


        if (alarmDetected) {

            doorAlarmActive = true;

            if (alarmStatus)
                alarmStatus.textContent = "ON";


            addLog(
                "SECURITY ALARM ACTIVATED."
            );

        }


        if (buzzerDetected) {

            addLog(
                "BUZZER ACTIVE — RTL signal detected."
            );

        }

    }
    catch (error) {
        console.error(error);
        addLog(
            "Unable to connect to alarm simulation."
        );
    }
}

function setLocked() {
    doorUnlocked = false;

    if (doorTimeoutTimer) {
        clearTimeout(doorTimeoutTimer);
        doorTimeoutTimer = null;
    }

    doorAlarmActive = false;

    if (lockIcon)
        lockIcon.textContent = "🔒";

    if (doorStatus)
        doorStatus.textContent = "LOCKED";

    if (doorMessage)
        doorMessage.textContent =
            "Authentication required to access the door.";

    document.body.classList.remove(
        "door-unlocked"
    );

    if (sensorStatus)
        sensorStatus.textContent = "CLOSED";

    if (alarmStatus)
        alarmStatus.textContent = "OFF";

    addLog(
        "Door locked."
    );

    addLog(
        "Door-open timer reset."
    );
}

if (emergencyBtn) {
    emergencyBtn.addEventListener("click", () => {
        doorUnlocked = true;

        if (lockIcon)
            lockIcon.textContent = "🔓";

        if (doorStatus)
            doorStatus.textContent =
                "EMERGENCY UNLOCK";

        if (doorMessage)
            doorMessage.textContent =
                "Emergency override is active.";

        if (emergencyStatus)
            emergencyStatus.textContent =
                "ACTIVE";

        if (alarmStatus)
            alarmStatus.textContent =
                "OFF";

        document.body.classList.add(
            "door-unlocked"
        );

        addLog(
            "EMERGENCY OVERRIDE ACTIVATED."
        );

        addLog(
            "Door unlocked through emergency override."
        );
    });
}

if (clearLogBtn) {
    clearLogBtn.addEventListener("click", () => {
        eventLog.innerHTML = "";
        addLog(
            "Security log cleared."
        );
    });
}


function updateSecurityDisplay() {

    if (attemptsDisplay) {

        attemptsDisplay.textContent =
            `${attempts} / 3`;

    }


    if (lockoutStatus) {

        lockoutStatus.textContent =
            lockedOut
                ? "ACTIVE"
                : "INACTIVE";

    }

}


updatePinDisplay();

updateSecurityDisplay();

addLog(
    "SecureLock system initialized."
);

addLog(
    "SystemVerilog security core online."
);

