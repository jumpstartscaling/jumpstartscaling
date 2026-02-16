module.exports = {
    apps: [
        {
            name: "jumpstartscaling",
            script: "./server.js",
            cwd: "/home/opc/sites/jumpstartscaling",
            env: {
                PORT: 8100,
                NODE_ENV: "production"
            }
        },
        {
            name: "chrisamaya",
            script: "npm",
            args: "run preview",
            cwd: "/home/opc/sites/chrisamaya",
            env: {
                NODE_ENV: "production"
            }
        }
    ]
};
