// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

// AUTO-GENERATED FILE. DO NOT MODIFY.
// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/http;
import ballerina/persist;
import load_tests.db;
import ballerina/io;
import ballerina/uuid;

const db:PatientInsert patient = {
    name: "Jane Doe",
    phoneNumber: "0711232345",
    age: 25,
    address: "Colombo",
    gender: db:MALE
};


service / on new http:Listener(9090) {
    
    private final db:Client dbClient;

    function init() returns error? {
        self.dbClient = check new ();
    }

    isolated resource function get insert\-doctors() returns http:InternalServerError & readonly|http:Created & readonly|http:Conflict & readonly {
        db:DoctorInsert doctor = {
            id: uuid:createRandomUuid(),
            name: "John Doe",
            phoneNumber: "0711232345",
            salary: 500.00,
            specialty: "Physician"
        };
        string[]|persist:Error result = self.dbClient->/doctors.post([doctor]);
        if result is persist:Error {
            io:println(result);
            return http:INTERNAL_SERVER_ERROR;
        }
        return http:CREATED;
    }

    isolated resource function get insert\-patients() returns http:InternalServerError & readonly|http:Created {
        int[]|persist:Error result = self.dbClient->/patients.post([patient]);
        if result is persist:Error {
            io:println(result);
            return http:INTERNAL_SERVER_ERROR;
        }
        return http:CREATED;
    }

    isolated resource function get insert\-appointments(int appointmentId) returns http:InternalServerError & readonly|http:Created & readonly|http:Conflict & readonly {
        db:AppointmentStatus[] statuses = [db:STARTED, db:SCHEDULED, db:ENDED];
        db:AppointmentInsert appointment = {
            id: appointmentId,
            doctorId: "id1",
            patientId: 1,
            reason: "Checkup",
            status: statuses[appointmentId % 3]
        };
        int[]|persist:Error result = self.dbClient->/appointments.post([appointment]);
        if result is persist:Error {
            io:println(result);
            return http:INTERNAL_SERVER_ERROR;
        }
        return http:CREATED;
    }


    isolated resource function get doctors/[string id]() returns db:Doctor|persist:Error? {
        db:Doctor doctor = check self.dbClient->/doctors/[id];
        return doctor;
    }

    isolated resource function get patients() returns db:Patient[]|error {
        stream<db:Patient, persist:Error?> patients = self.dbClient->/patients.get();
        return from db:Patient patient in patients
            select patient;
    }

    isolated resource function get appointments() returns db:AppointmentWithRelations[]|error {
        stream<db:AppointmentWithRelations, persist:Error?> appointments = self.dbClient->/appointments.get();
        return from db:AppointmentWithRelations appointment in appointments
            where appointment.status == db:STARTED
            select appointment;
    }
}
