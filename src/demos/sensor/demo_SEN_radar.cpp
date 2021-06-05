// =============================================================================
// PROJECT CHRONO - http://projectchrono.org
//
// Copyright (c) 2019 projectchrono.org
// All rights reserved.
//
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file at the top level of the distribution and at
// http://projectchrono.org/license-chrono.txt.
//
// =============================================================================
// Authors: Han Wang
// =============================================================================
//
// Chrono demonstration of a radar sensor
//
// =============================================================================

#include <cstdio>

#include "chrono/utils/ChUtilsCreators.h"
#include "chrono_thirdparty/filesystem/path.h"
#include "chrono/physics/ChSystemNSC.h"
#include "chrono/physics/ChBodyEasy.h"
#include "chrono/geometry/ChTriangleMeshConnected.h"
#include "chrono/assets/ChTriangleMeshShape.h"

#include "chrono_sensor/Sensor.h"
#include "chrono_sensor/ChSensorManager.h"
#include "chrono_sensor/ChRadarSensor.h"
#include "chrono_sensor/ChLidarSensor.h"
#include "chrono_sensor/filters/ChFilterAccess.h"
#include "chrono_sensor/filters/ChFilterVisualize.h"
#include "chrono_sensor/filters/ChFilterRadarProcess.h"
#include "chrono_sensor/filters/ChFilterRadarSavePC.h"
#include "chrono_sensor/filters/ChFilterSavePtCloud.h"
#include "chrono_sensor/filters/ChFilterRadarVisualizeCluster.h"
#include "chrono_sensor/filters/ChFilterPCfromDepth.h"
#include "chrono_sensor/filters/ChFilterVisualizePointCloud.h"

#include "chrono_sensor/ChCameraSensor.h"
#include "chrono_sensor/ChSensorManager.h"
#include "chrono_sensor/filters/ChFilterAccess.h"
#include "chrono_sensor/filters/ChFilterGrayscale.h"
#include "chrono_sensor/filters/ChFilterSave.h"
#include "chrono_sensor/filters/ChFilterVisualize.h"
#include "chrono_sensor/filters/ChFilterCameraNoise.h"
#include "chrono_sensor/filters/ChFilterImageOps.h"

using namespace chrono;
using namespace chrono::geometry;
using namespace chrono::sensor;
// using namespace irr;
// using namespace irr::core;
// using namespace irr::scene;
// using namespace irr::video;

// ------------------------------------
// Radar Parameters
// ------------------------------------

// Update rate in Hz
float update_rate = 5.f;

// horizontal field of view of camera
int alias_factor = 1;
CameraLensModelType lens_model = CameraLensModelType::PINHOLE;
// Exposure (in seconds) of each image
float exposure_time = 0.02f;

// Number of horizontal and vertical samples
unsigned int horizontal_samples = 100;
unsigned int vertical_samples = 100;

// Field of View
float horizontal_fov = CH_C_PI / 9;           // 20 degree scan
float max_vert_angle = (float)CH_C_PI / 15;   // 12 degrees up
float min_vert_angle = (float)-CH_C_PI / 15;  // 12 degrees down

// camera can have same view as radar
float aspect_ratio = horizontal_fov / (max_vert_angle - min_vert_angle);
float width = 960;
float height = width / aspect_ratio;

// max detection range
float max_distance = 100;

// lag time
float lag = 0.f;

// Collection window for the radar
float collection_time = 1 / update_rate;  // typically 1/update rate

// Output directories
const std::string out_dir = "RADAR_OUTPUT/";
// ------------------------------------
//  Simulation Parameters
// ------------------------------------

// Simulation step size
double step_size = 1e-3;

// Simulation end time
float end_time = 2000.0f;

int main(int argc, char* argv[]) {
    GetLog() << "Copyright (c) 2019 projectchrono.org\nChrono version: " << CHRONO_VERSION << "\n\n";

    // -----------------
    auto material = chrono_types::make_shared<ChMaterialSurfaceNSC>();
    // Create the system
    // -----------------
    ChSystemNSC mphysicalSystem;
    mphysicalSystem.Set_G_acc(ChVector<>(0, 0, 0));

    // ----------------------
    // color visual materials
    // ----------------------
    auto red = chrono_types::make_shared<ChVisualMaterial>();
    red->SetDiffuseColor({1, 0, 0});
    red->SetSpecularColor({1.f, 1.f, 1.f});

    auto green = chrono_types::make_shared<ChVisualMaterial>();
    green->SetDiffuseColor({0, 1, 0});
    green->SetSpecularColor({1.f, 1.f, 1.f});

    // -------------------------------------------
    // add a few box bodies to be sense by a radar
    // -------------------------------------------
    auto floor = chrono_types::make_shared<ChBodyEasyBox>(1000, 20, 1, 1000, true, false);
    floor->SetPos({0, 0, -1});
    floor->SetBodyFixed(true);
    //    floor->SetWvel_par(ChVector<>(-0.2,-0.4,-0.3));
    floor->SetPos_dt(ChVector<>(0.1, 0, 0));
    mphysicalSystem.Add(floor);
    {
        auto asset = floor->GetAssets()[0];
        if (auto visual_asset = std::dynamic_pointer_cast<ChVisualization>(asset)) {
            visual_asset->material_list.push_back(green);
        }
    }

    for (int i = 0; i < 10; i++) {
        int x = rand() % 50;
        int y = 1;
        int z = 0;
        auto box_body = chrono_types::make_shared<ChBodyEasyBox>(0.5, 0.5, 0.5, 1000, true, false);
        box_body->SetPos({5 + x, y, z});
        box_body->SetPos_dt({-0.5, 0, 0});
        mphysicalSystem.Add(box_body);
        {
            auto asset = box_body->GetAssets()[0];
            if (auto visual_asset = std::dynamic_pointer_cast<ChVisualization>(asset)) {
                visual_asset->material_list.push_back(red);
            }
        }
    }

    for (int i = 0; i < 10; i++) {
        int x = rand() % 50;
        int y = -1;
        int z = 0;
        auto box_body = chrono_types::make_shared<ChBodyEasyBox>(0.5, 0.5, 0.5, 1000, true, false);
        box_body->SetPos({10 - x, y, z});
        box_body->SetPos_dt({0.5, 0, 0});
        mphysicalSystem.Add(box_body);
        {
            auto asset = box_body->GetAssets()[0];
            if (auto visual_asset = std::dynamic_pointer_cast<ChVisualization>(asset)) {
                visual_asset->material_list.push_back(red);
            }
        }
    }

    // -----------------------
    // Create a sensor manager
    // -----------------------
    auto manager = chrono_types::make_shared<ChSensorManager>(&mphysicalSystem);
    float intensity = 0.3;
    manager->scene->AddPointLight({100, 100, 100}, {intensity, intensity, intensity}, 500);
    manager->scene->AddPointLight({-100, 100, 100}, {intensity, intensity, intensity}, 500);
    manager->scene->AddPointLight({100, -100, 100}, {intensity, intensity, intensity}, 500);
    manager->scene->AddPointLight({-100, -100, 100}, {intensity, intensity, intensity}, 500);
    manager->SetVerbose(true);
    // -----------------------------------------------
    // Create a radar and add it to the sensor manager
    // -----------------------------------------------
    auto offset_pose = chrono::ChFrame<double>({0, 0, 1}, Q_from_AngZ(0));

    auto radar =
        chrono_types::make_shared<ChRadarSensor>(floor, update_rate, offset_pose, horizontal_samples, vertical_samples,
                                                 horizontal_fov, max_vert_angle, min_vert_angle, max_distance);
    radar->SetName("Radar Sensor");
    radar->SetLag(lag);
    radar->SetCollectionWindow(collection_time);

    radar->PushFilter(chrono_types::make_shared<ChFilterRadarProcess>("PC from Range"));
    radar->PushFilter(chrono_types::make_shared<ChFilterRadarVisualizeCluster>(640, 480, 1, "Radar Clusters"));
    const std::string out_dir = "RADAR_OUPUT/";
    manager->AddSensor(radar);

    auto lidar =
        chrono_types::make_shared<ChLidarSensor>(floor,                                  // body lidar is attached to
                                                 update_rate,                            // scanning rate in Hz
                                                 offset_pose,                            // offset pose
                                                 horizontal_samples,                     // number of horizontal samples
                                                 vertical_samples,                       // number of vertical channels
                                                 horizontal_fov,                         // horizontal field of view
                                                 max_vert_angle, min_vert_angle, 100.0f  // vertical field of view
        );
    lidar->SetName("Lidar Sensor 1");
    lidar->SetLag(lag);
    lidar->SetCollectionWindow(collection_time);
    lidar->PushFilter(chrono_types::make_shared<ChFilterPCfromDepth>());
    lidar->PushFilter(chrono_types::make_shared<ChFilterVisualizePointCloud>(width, height, 2, "Radar Return"));
    //    manager->AddSensor(lidar);

    auto cam_offset_pose = chrono::ChFrame<double>({0, 0, 1}, Q_from_AngZ(0));
    auto cam1 = chrono_types::make_shared<ChCameraSensor>(floor,            // body camera is attached to
                                                          update_rate,      // update rate in Hz
                                                          cam_offset_pose,  // offset pose
                                                          width,            // image width
                                                          height,           // image height
                                                          horizontal_fov,   // camera's horizontal field of view
                                                          alias_factor,     // supersample factor for antialiasing
                                                          lens_model,
                                                          false);  // FOV
    cam1->SetName("World Camera Sensor");
    cam1->SetLag(lag);
    cam1->SetCollectionWindow(exposure_time);
    cam1->PushFilter(chrono_types::make_shared<ChFilterVisualize>(width, height, "World Ray Tracing"));
    manager->AddSensor(cam1);

    // -------------------
    // Simulate the system
    // -------------------
    double render_time = 0;
    float ch_time = 0.0;

    while (ch_time < end_time) {
        manager->Update();

        mphysicalSystem.DoStepDynamics(step_size);

        // Get the current time of the simulation
        ch_time = (float)mphysicalSystem.GetChTime();
    }
}