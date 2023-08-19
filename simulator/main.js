import * as THREE from 'three';

// const scene = new THREE.Scene();
// const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);

// const renderer = new THREE.WebGLRenderer();
// renderer.setSize(window.innerWidth, window.innerHeight);
// document.body.appendChild(renderer.domElement);

// const geometry = new THREE.BoxGeometry(1, 1, 1);
// const material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
// const cube = new THREE.Mesh(geometry, material);
// scene.add(cube);

// camera.position.z = 5;

// function animate() {
//     requestAnimationFrame(animate);

//     cube.rotation.x += 0.01;
//     cube.rotation.y += 0.01;

//     renderer.render(scene, camera);
// }

// animate();

var DisplaceMaterial = function (param) {
    THREE.MeshBasicMaterial.call(this);
    this.type = 'ShaderMaterial';
    this.setValues(param);

    this.uniforms = THREE.UniformsUtils.clone(THREE.ShaderLib.basic.uniforms);
    this.uniforms.displaceMap = { type: 't', value: param.displaceMap };
    this.uniforms.maxDisplacement = { type: 'f', value: param.maxDisplacement || 0 };

    var originalShader = THREE.ShaderLib.basic.vertexShader;

    var vertex = originalShader.replace('void main()', 'void originalMain()');
    vertex = vertex + "\n" + document.getElementById('vertexShader').textContent;

    this.vertexShader = vertex;
    this.fragmentShader = THREE.ShaderLib.basic.fragmentShader;
}
DisplaceMaterial.prototype = Object.create(THREE.MeshBasicMaterial.prototype);
DisplaceMaterial.prototype.constructor = DisplaceMaterial;


var radius = 250;
var r;
var posX = 0.5;
var posY = 0.5;
var mousePosX, mousePosY;

var canvas;

var scene,
    camera,
    raycastCamera,
    renderer,
    plane,
    material,
    sphere,
    sphereMaterial,
    texture,
    fov = 75,
    container,
    origin;

function setup() {
    canvas = createCanvas(512, 512, 'p2d');
    noStroke();
}

function draw() {
    background(255);

    for (r = radius; r > 0; r--) {
        fill(map(r, 0, radius, 0, 255));
        ellipse(512 * posX, 512 * posY, r, r);
    }

    if (texture) {
        texture.needsUpdate = true;
    }
}

function mouseMove(e) {
    mousePosX = e.clientX / window.innerWidth;
    mousePosY = e.clientY / window.innerHeight;
}

function deg2rad(value) {
    return (value / 180 * Math.PI);
}


window.addEventListener('load', function () {
    origin = new THREE.Vector3(0, 0, 0);

    container = document.getElementById('container');

    scene = new THREE.Scene();

    camera = new THREE.PerspectiveCamera(fov, window.innerWidth / window.innerHeight, 1, 10000);
    camera.position.y = 0;
    camera.position.z = 70;
    camera.target = origin;

    scene.add(camera);

    texture = new THREE.Texture(canvas.canvas);
    texture.needsUpdate = true;

    material = new DisplaceMaterial({
        color: 0xffffff,
        displaceMap: texture,
        maxDisplacement: 20,
        wireframe: true
    });

    plane = new THREE.Mesh(new THREE.PlaneGeometry(100, 100, 20, 20), material);
    plane.position.y = -20;
    plane.rotation.set(deg2rad(-90), 0, 0)
    scene.add(plane);

    sphereMaterial = new THREE.MeshBasicMaterial({
        color: 0xffffff,
        wireframe: true
    });

    var sphereGeo = new THREE.IcosahedronGeometry(18, 1);
    sphere = new THREE.Mesh(sphereGeo, sphereMaterial);
    scene.add(sphere);

    renderer = new THREE.WebGLRenderer();
    renderer.setSize(window.innerWidth, window.innerHeight);
    container.appendChild(renderer.domElement);

    render();

    document.addEventListener('mousemove', mouseMove);
    window.addEventListener('resize', resize);
});

function resize() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
}


function render() {
    sphere.rotation.y += 0.01;
    var vector = new THREE.Vector3();

    vector.set(
        mousePosX * 2 - 1,
        - mousePosY * 2 + 1,
        0.5);

    vector.unproject(camera);

    var ray = new THREE.Raycaster(camera.position, vector.sub(camera.position).normalize());
    var intersects = ray.intersectObject(plane, false);

    if (intersects.length) {
        posX = (intersects[0].point.x + 50) * 0.01;
        posY = (intersects[0].point.z + 50) * 0.01;
        sphere.position.set(intersects[0].point.x, -8, intersects[0].point.z)
    }
    else {
        posX = posY = -5;
    }

    renderer.render(scene, camera);
    requestAnimationFrame(render);
}