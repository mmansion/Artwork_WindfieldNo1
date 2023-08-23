import * as THREE from 'three';

import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { GUI } from 'three/addons/libs/lil-gui.module.min.js';
// import {
//     Foo,
//     Bar
// } from './Test.js';

// let foo = new Foo();
// let bar = new Bar();

import {
    Boid3D,
    Boid2D
} from './Boids.js';

//import control panel from public folder
import ControlPanel from './public/ControlPanel.js';

//-------------------------------------------
//SETTTINGS

const UNITS_PER_FOOT = 10;
const TILE_SIZE = 4; //ft
const PIXELS_PER_FOOT = 4;
const PIXEL_SIZE = 2;
const TILE_OFFSET = 8; //center sculpture at origin

const tileGrid = [ // (16x5) rows: W->E, cols: N->S
    // a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p
    [  0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0 ], // 1
    [  1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0 ], // 2
    [  1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1 ], // 3
    [  0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1 ], // 4
    [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1 ], // 5
];

//-------------------------------------------
let mesh, mesh2, renderer, scene, camera, controls;
let count = 0;



// function animate() {
//     requestAnimationFrame(animate);
//     renderer.render(scene, camera);

// }

function addHelpers() {
    //add an arrow helper for the x, y, z axis
    const axesHelper = new THREE.AxesHelper(100);
    scene.add(axesHelper);
}



// const scene = new THREE.Scene();

//-------------------------------------------


function addGrid() {

    const size = 800;
    const divisions = 20;
 
    const gridHelper = new THREE.GridHelper(size, divisions);
    
    //change color of grid lines
    // gridHelper.material.color = new THREE.Color(0x0000ff);
    
    //change material of grid lines
    gridHelper.material = new THREE.LineBasicMaterial({
        // make a transparent line color
        color: 0x0000ff,
        opacity: 0.2,
        transparent: true,
        //make thin lines
        linewidth: 1
    });

    scene.add(gridHelper);
}



//-------------------------------------------

class Led {
    constructor(pos) {
        this._geometry = new THREE.SphereGeometry(PIXEL_SIZE, 16, 16);
        this._material = new THREE.MeshBasicMaterial({ color: 0x0000ff });
        this._object   = new THREE.Mesh(this._geometry, this._material);
        this._object.position.set(pos.x, pos.y, pos.z);
    }
    addToScene(scene) {
        scene.add(this._object);
    }
    addToGroup(group) {
        group.add(this._object);
    }
}

class Tile {
    constructor(pos) {
        this._group = new THREE.Group();
        this._group.position.set(UNITS_PER_FOOT/2, 0, UNITS_PER_FOOT/2);
        let groupPos = this._group.position;
        groupPos.x += pos.x;
        groupPos.y += pos.y;
        groupPos.z += pos.z;

        this._group.position.set(groupPos.x, groupPos.y, groupPos.z);
        
        let size = TILE_SIZE * UNITS_PER_FOOT;

        const geometry = new THREE.PlaneGeometry(size, size);   
        const material = new THREE.MeshBasicMaterial({ color: 0x000000, wireframe: true, wireframeLinewidth: 40, side: THREE.DoubleSide });
        const plane = new THREE.Mesh(geometry, material);
        plane.rotation.x = Math.PI / 2;
        plane.position.set(size / 2 - UNITS_PER_FOOT/2, 0, size/2-UNITS_PER_FOOT/2);
        this._group.add(plane);

        // console.log(this._group.position);
        
        //create a 4x4 grid of leds
        for (let i = 0; i < PIXELS_PER_FOOT; i++) {
            for (let j = 0; j < PIXELS_PER_FOOT; j ++) {
                let led = new Led({ 
                    x: i * UNITS_PER_FOOT, 
                    y: 0, z: j * UNITS_PER_FOOT 
                });
                led.addToGroup(this._group);
            }
        }
    }
    addToScene(scene) {
        scene.add(this._group);
    }
    addToGroup(group) {
        group.add(this._group);
    }
}

//-------------------------------------------

function addSculpture() {

    /*
    // renderer
    renderer = new THREE.WebGLRenderer();
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(window.devicePixelRatio);
    document.body.appendChild(renderer.domElement);

    // scene
    scene = new THREE.Scene();
    scene.background = new THREE.Color(0xffffff);

    // camera
    const frustumSize = 1000;
    const aspect = window.innerWidth / window.innerHeight;

    camera = new THREE.OrthographicCamera(frustumSize * aspect / - 2, frustumSize * aspect / 2, frustumSize / 2, frustumSize / - 2, -100000, 100000);
    camera.up.set(0, 0, 1);
    camera.position.set(0, 100, 0); //move camera up overhead
    camera.rotateX(Math.PI/2); //rotate camera to look down
    camera.lookAt(0, 0, 0);
    camera.zoom = 1;
    camera.updateProjectionMatrix();

    // camera.rotateX(Math.PI/2);

    controls
    controls = new OrbitControls(camera, renderer.domElement);
    controls.touches.ONE = THREE.TOUCH.PAN;
    // controls.touches.TWO = THREE.TOUCH.DOLLY_ROTATE;

    // OrbitControls now supports panning parallel to the "ground plane", and it is the default.
    controls.screenSpacePanning = true;
    controls.target.set(5, 0, 0);
    controls.update();
    controls.addEventListener("change", event => {
        console.log(controls.object.position);
    });

    // ambient
    // scene.add(new THREE.AmbientLight(0xffffff));

    // light
    var light = new THREE.DirectionalLight(0xffffff, 10);
    light.position.set(0, 2, 2);
    // scene.add(light);

    // axes
    scene.add(new THREE.AxesHelper(20));

    // geometry
    var geometry = new THREE.PlaneGeometry(5, 5);

    // material
    var material = new THREE.MeshPhongMaterial({
        color: 0x00ffff,
        side: THREE.DoubleSide
    });


    // mesh
    mesh = new THREE.Mesh(geometry, material);
    scene.add(mesh);

    var geometry2 = new THREE.PlaneGeometry(3, 3);
    var material2 = new THREE.MeshPhongMaterial({
        color: 0x00ffff,
        side: THREE.DoubleSide
    });
    mesh2 = new THREE.Mesh(geometry2, material2);
    mesh2.position.x = 5;
    scene.add(mesh2);
    */
    addGrid();
    addHelpers();

    let tileUnitSize = TILE_SIZE * UNITS_PER_FOOT;

    //loop through tileGrid and add tiles to scene
    for (let i = 0; i < tileGrid.length; i++) {
        for (let j = 0; j < tileGrid[i].length; j++) {
            if (tileGrid[i][j] === 1) {
                let tilePos = { 
                    x: i * UNITS_PER_FOOT * TILE_SIZE * -1, 
                    y: 0, 
                    z: j * tileUnitSize - tileUnitSize * TILE_OFFSET};
                let tile = new Tile(tilePos).addToScene(scene);
            }
        }
    }

    // animate();
// 
    // TODO: add control panel 
    // let cpanel = new ControlPanel({
    //     camera: camera,
    //     renderer: renderer,
    // });
}

class BoidsRenderer {
    updateFunction;
    constructor(type = "2D") {
        this.type = type;

        /* camera
        //boids example

        // this.camera = type === "2D" ?
        //     new THREE.OrthographicCamera(window.innerWidth / -2, window.innerWidth / 2, window.innerHeight / -2, window.innerHeight / 2, 1, 1000) :
        //     new THREE.PerspectiveCamera(70, window.innerWidth / window.innerHeight, 0.01, 1000)
        
        // this.camera.position.z = 20;
        */
        //-------------------------------------------
        // camera (mikhail)
        const frustumSize = 1000;
        const aspect = window.innerWidth / window.innerHeight;
        this.camera = new THREE.OrthographicCamera(frustumSize * aspect / - 2, frustumSize * aspect / 2, frustumSize / 2, frustumSize / - 2, -100000, 100000);
        this.camera.up.set(0, 0, 1);
        this.camera.position.set(0, 100, 0); //move this.camera up overhead
        this.camera.rotateX(Math.PI / 2); //rotate this.camera to look down
        this.camera.lookAt(0, 0, 0);
        this.camera.zoom = 1;
        this.camera.updateProjectionMatrix();

        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(0xffffff);
        this.renderer = new THREE.WebGLRenderer({
            antialias: true
        });
        this.renderContainer = document.getElementById('renderContainer');
        this.resize();
        this.renderContainer.appendChild(this.renderer.domElement)
        window.addEventListener("resize", this.resize)

        this.lastRender = 0;

        this.animationFrame = 0;

        this.addGrid();
        this.addSculpture();
    }

    addSculpture = () => {
        let tileUnitSize = TILE_SIZE * UNITS_PER_FOOT;

        //loop through tileGrid and add tiles to scene
        for (let i = 0; i < tileGrid.length; i++) {
            for (let j = 0; j < tileGrid[i].length; j++) {
                if (tileGrid[i][j] === 1) {
                    let tilePos = {
                        x: i * UNITS_PER_FOOT * TILE_SIZE * -1,
                        y: 0,
                        z: j * tileUnitSize - tileUnitSize * TILE_OFFSET
                    };
                    let tile = new Tile(tilePos).addToScene(this.scene);
                }
            }
        }
    }

    addGrid = () => {
        const size = 800;
        const divisions = 20;

        const gridHelper = new THREE.GridHelper(size, divisions);

        //change color of grid lines
        // gridHelper.material.color = new THREE.Color(0x0000ff);

        //change material of grid lines
        gridHelper.material = new THREE.LineBasicMaterial({
            // make a transparent line color
            color: 0x0000ff,
            opacity: 0.2,
            transparent: true,
            //make thin lines
            linewidth: 1
        });

        this.scene.add(gridHelper);
    }

    setMode2d = () => {
        // if (this.camera.isOrthographicCamera) return
        // this.type = "2D";
        // this.camera = new THREE.OrthographicCamera(window.innerWidth / -2, window.innerWidth / 2, window.innerHeight / -2, window.innerHeight / 2, 1, 1000)

    }
    setMode3d = () => {
        // if (!this.camera.isOrthographicCamera) return
        // this.type = "3D";
        // this.camera = new THREE.PerspectiveCamera(70, window.innerWidth / window.innerHeight, 0.01, 1000);
    }

    resize = () => {
        this.camera.isOrthographicCamera ?
            this.resizeOrtho() :
            this.camera.aspect = this.renderContainer.clientWidth / this.renderContainer.clientHeight;

        this.camera.updateProjectionMatrix();
        this.renderer.setSize(this.renderContainer.clientWidth, this.renderContainer.clientHeight);

    }

    resizeOrtho = () => {
        this.camera.left = window.innerWidth / -2;
        this.camera.right = window.innerWidth / 2;
        this.camera.top = window.innerHeight / -2;
        this.camera.bottom = window.innerHeight / 2;
    }

    start = () => {
        if (this.scene.children.length) {
            if (this.updateFunction) {
                this.lastRender = Date.now();
                return this.runWithUpdate();
            }
            this.run();
        }
    }

    stop = () => {
        cancelAnimationFrame(this.animationFrame);
    }
    
    run = () => {
        this.animationFrame = requestAnimationFrame(this.run);
        this.render();
    }
    
    runWithUpdate = () => {
        this.animationFrame = requestAnimationFrame(this.runWithUpdate);
        const now = Date.now();
        this.updateFunction(now - this.lastRender);
        this.render();
        this.lastRender = now;
    }

    render = () => {
        this.renderer.render(this.scene, this.camera);
    }
}

class Boids {
    constructor(options = {
        /* accelerationVector: new THREE.Vector3(),
        velocityVector: new THREE.Vector3(), */
        maxForce: 0.03,
        maxSpeed: 0.4,
        seperationDist: 1.1,
        allignDist: 10,
        cohesionDist: 10,
        homeDist: 200.0,
        seperationWeight: 1.5,
        allignmentWeight: 1.1,
        cohesionWeight: 1.0,
        homeWeight: 1.1

    }) {
        this.boidsGroup = new THREE.Group();

        this.options = options;
    }



    addBoid = (boid) => {
        this.boidsGroup.add(boid);
        return this.boidsGroup;
    }


    createBoid = (posX = 0, posY = 0, posZ = 0, type = "2D") => {
        /* const geometry = new THREE.ConeGeometry(1, 3, 5); */
        const material = new THREE.MeshBasicMaterial({ color: 0x0000ff });
        const mesh = type === "2D" ?
            new Boid2D(new THREE.ConeGeometry(8, 20, 5), material
                /* , {
                                ...this.options,
                                homeDist: this.minScreen()
                            } */
            ) :
            new Boid3D(new THREE.ConeGeometry(1, 3, 5), material /* , this.options */);

        mesh.position.set(posX, posY, posZ);
        this.boidsGroup.add(mesh);
        return this.boidsGroup;
    }

    createBoid2D = (posX, posY) => this.createBoid(posX, posY, 0, "2D");


    createBoid3D = (posX, posY, posZ) => this.createBoid(posX, posY, posZ)


    clearBoids = () => {
        this.boidsGroup = new THREE.Group();
    }

    static minScreen = () => {
        // returns the smaller dimension of the container currently the window
        return window.innerHeight > window.innerWidth ? window.innerWidth : window.innerHeight;
    }

    createRandom = (count = 60, type = "2D") => {
        this.clearBoids();
        if (type === "2D") {
            for (let i = 0; i < count; i++) {
                const posXScreenRange = (Math.random() - 0.5) * window.innerWidth;
                const posYScreenRange = (Math.random() - 0.5) * window.innerHeight;
                this.createBoid2D(posXScreenRange, posYScreenRange);
            }
        } else {
            for (let i = 0; i < count; i++) {
                this.createBoid3D(Math.random() - 0.5, Math.random() - 0.5, Math.random() - 0.5);
            }

        }
        return this.boids;
    }

    createRandom2D = (count) => this.createRandom(count, "2D");

    createRandom3D = (count) => this.createRandom(count, "3D");

    getCenter = () => {
        const sceneSize = this.boidsGroup.children.length;
        let averagePos = new THREE.Vector3(0, 0, 0);
        if (!sceneSize) return averagePos;

        for (let i = 0; i < sceneSize; i++) {
            averagePos.add(this.boidsGroup.children[i].position);
        }
        return averagePos.divideScalar(sceneSize);
    }

    update = () => {
        const boidsLen = this.boidsGroup.children.length;
        for (let i = 0; i < boidsLen; i++) {
            this.boidsGroup.children[i].update(this.boidsGroup.children, this.options);
        }
    }

}

class App {
    optionsContainer;
    cameraController;
    cameraButton;
    numInputs = {};
    constructor() {
        this.renderer = new BoidsRenderer("2D");
        this.boids = new Boids();
        this.count = 400;
        this.mode = "2D";
        this.cameraMode = "lookAt";

        this.setCameraDefault();

        this.optionsOpen = false;
        this.running = false;
        this.boidsReady = false;

        // save initial options for the case that you want to restore them and not reload the page
        this.initialBoidsOptions = {
            ...this.boids.options
        }

        this.initialCameraPos = this.renderer.camera.position.clone();

        this.createDOMControlls();

    }

    

    addSculpture() {

    }

    createDOMControlls = () => {
        /* add event listeners to the dom elements */
        this.optionsContainer = document.querySelector('#optionsContainer')
        const toggle = document.querySelector("#optionsToggle");

        toggle.addEventListener('click', (e) => {
            this.optionsContainer.classList.toggle('open')
        })

        this.createButtonControlls();

        this.createOptionsInputs();

    }

    resetOptions3d = () => {
        /* reset boids options */
        this.boids.options = {
            ...this.initialBoidsOptions
        };
        /* rest renderer camera position */
        this.renderer.camera.position.copy(this.initialCameraPos);
        this.setCameraDefault();
    }

    resetOptions2d = () => {
        this.boids.options = boids2dDefaultValues();

    }

    createButtonControlls = () => {
        document.querySelector('#startStopButton').addEventListener('click', (e) => {
            this.stopStart();
            e.target.innerHTML = this.running ? "STOP" : "START";
        })

        document.querySelector('#resetButton').addEventListener('click', (e) => {
            /* reset boids options */
            this.mode == "2D" ? this.resetOptions2d() : this.resetOptions3d();
            /* update inputs */
            this.setNumInputs();
        })

        document.querySelector('#button2D').addEventListener('click', (e) => {
            this.setMode2D();
        })

        // document.querySelector('#button3D').addEventListener('click', (e) => {
        //     this.setMode3D();
        // })
        // this.cameraButton = document.querySelector('#freeCamera')
        // this.cameraButton.addEventListener('click', (e) => {
        //     if (this.mode === "2D") return;
        //     if (this.cameraMode === "lookAt") {
        //         // this.setCameraFree();
        //     } else {
        //         this.setCameraDefault();
        //     }
        // })
    }

    updateCameraButton = () => {
        if (!this.cameraButton) return;
        if (this.mode === "2D") {
            this.cameraButton.disabled = true;
        } else {
            this.cameraButton.disabled = false;
            this.cameraButton.innerHTML = this.cameraMode === "lookAt" ? "Free Camera" : "Follow Camera";

        }
    }

    createOptionsInputs = () => {
        const content = document.querySelector('#optionsContent');
        for (const key in this.boids.options) {
            /* create input label */
            const label = document.createElement('label');
            label.innerHTML = key;

            content.appendChild(label);

            /* create input */
            const node = document.createElement('input')
            node.type = 'number'
            node.id = `${key}_input`
            node.classList = "numOptions"
            node.value = this.boids.options[key]
            node.addEventListener('input', (e) => {
                console.log(e);

                this.boids.options[key] = e.target.value || 0;
            })

            content.appendChild(node);

            this.numInputs[key] = node;
        }
    }



    // setCameraFree = () => {
    //     if (this.mode === "2D") return;
    //     this.cameraController = addCameraControlls(this.renderer);
    //     const boidSpeed = this.boids.options.maxSpeed;
    //     this.cameraController.movementSpeed = boidSpeed;
    //     this.cameraController.rollSpeed = 0.002;
    //     this.cameraController.dragToLook = true;

    //     this.renderer.updateFunction = (delta) => {
    //         this.boids.update();
    //         this.cameraController.update(delta);
    //     };
    //     this.cameraMode = "free";
    //     this.mode = "3D";
    //     alert("hold right click to look around and WASD to move")

    //     this.updateCameraButton();
    // }

    setCameraDefault = () => {
        if (this.mode === "2D") return;
        this.renderer.updateFunction = () => {
            this.boids.update();
            this.renderer.camera.lookAt(this.boids.getCenter())
        };
        this.cameraMode = "lookAt";
        this.mode = "3D";

        this.updateCameraButton();
    }

    setMode2D = () => {
        if (this.mode === "2D") return;
        this.stop();
        this.renderer.setMode2d();
        this.mode = "2D";
        this.boidsReady = false;
        /* after switching mode create new boids */

        if (this.renderer.camera.isOrthographicCamera) {
            this.renderer.updateFunction = () => {
                this.boids.update();
            }
            this.start();
        }

        this.updateCameraButton();
    }

    setMode3D = () => {
        if (this.mode === "3D") return;
        this.stop();
        this.renderer.setMode3d();
        this.mode = "3D";
        this.boidsReady = false;
        /* after switching mode create new boids */
        this.setCameraDefault();
        this.start();
    }

    createBoids = () => {
        this.renderer.scene.remove(this.boids.boidsGroup);
        this.mode === "2D" ? (
            this.boids.createRandom2D(this.count),
            // 2d renderer has a way different dimensions of the view so options need to be adjusted
            this.boids.options = boids2dDefaultValues()

        ) :
            (
                this.boids.createRandom3D(this.count),
                this.boids.options = {
                    ...this.initialBoidsOptions
                }
            );
        this.renderer.scene.add(this.boids.boidsGroup);
        this.boidsReady = true;
        this.setNumInputs();
    }

    setNumInputs = () => {
        // sync the options with the dom values
        for (const key in this.numInputs) {
            this.numInputs[key].value = this.boids.options[key];
        }
    }

    stop = () => {
        if (!this.running) return;
        this.renderer.stop();
        this.running = false;
    }

    start = () => {
        if (!this.boidsReady) this.createBoids();
        this.renderer.start();
        this.running = true;
    }

    stopStart = () => this.running ? this.stop() : this.start()

}
const boids2dDefaultValues = () => {
    return {
        maxForce: 0.20,
        maxSpeed: 1.6,
        seperationDist: 3.2,
        allignDist: 40,
        cohesionDist: 40,
        homeDist: Boids.minScreen() | 200,
        seperationWeight: 1.5,
        allignmentWeight: 1.1,
        cohesionWeight: 1.0,
        homeWeight: 1.1
    }
}


const myApp = new App();
myApp.start();
myApp.setMode3D();
myApp.setMode2D();

