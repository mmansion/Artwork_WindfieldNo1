//import gui from threejs
// import * as dat from 'dat.gui';
import {GUI} from 'dat.gui';

export default class ControlPanel {
    
    constructor(camera) {
    
        this._gui = new GUI();
        this._cameraSettings = this._gui.addFolder('Camera');
        //open the folder
        this._cameraSettings.open();
        this._cameraSettings.add(camera.position, 'x', -100, 100).onChange((val) => camera.updateProjectionMatrix());
        // this._cameraSettings.add(camera.position, 'y', 100, 10000).onChange((val) => camera.updateProjectionMatrix());
        this._cameraSettings.add(camera.position, 'z', -100, 100).onChange((val) => camera.updateProjectionMatrix());
        this._cameraSettings.add(camera, 'zoom', 0.1, 2).onChange((val) => camera.updateProjectionMatrix());
   }


}