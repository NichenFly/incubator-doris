// Modifications copyright (C) 2017, Baidu.com, Inc.
// Copyright 2017 The Apache Software Foundation

// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

namespace cpp palo
namespace java com.baidu.palo.thrift

include "Status.thrift"
include "Types.thrift"
include "PaloInternalService.thrift"

struct TColumn {
    1: required string column_name
    2: required Types.TColumnType column_type
    3: optional Types.TAggregationType aggregation_type
    4: optional bool is_key
    5: optional bool is_allow_null
    6: optional string default_value
    7: optional bool is_bloom_filter_column
}

struct TTabletSchema {
    1: required i16 short_key_column_count
    2: required Types.TSchemaHash schema_hash
    3: required Types.TKeysType keys_type
    4: required Types.TStorageType storage_type
    5: required list<TColumn> columns
    6: optional double bloom_filter_fpp
}

struct TCreateTabletReq {
    1: required Types.TTabletId tablet_id
    2: required TTabletSchema tablet_schema
    3: optional Types.TVersion version
    4: optional Types.TVersionHash version_hash
    5: optional Types.TStorageMedium storage_medium
    6: optional bool in_restore_mode
}

struct TDropTabletReq {
    1: required Types.TTabletId tablet_id
    2: optional Types.TSchemaHash schema_hash
}

struct TAlterTabletReq{
    1: required Types.TTabletId base_tablet_id
    2: required Types.TSchemaHash base_schema_hash
    3: required TCreateTabletReq new_tablet_req
}

struct TClusterInfo {
    1: required string user
    2: required string password
}

struct TPushReq {
    1: required Types.TTabletId tablet_id
    2: required Types.TSchemaHash schema_hash
    3: required Types.TVersion version
    4: required Types.TVersionHash version_hash
    5: required i64 timeout
    6: required Types.TPushType push_type
    7: optional string http_file_path
    8: optional i64 http_file_size
    9: optional list<PaloInternalService.TCondition> delete_conditions
    10: optional bool need_decompress
}

struct TCloneReq {
    1: required Types.TTabletId tablet_id
    2: required Types.TSchemaHash schema_hash
    3: required list<Types.TBackend> src_backends
    4: optional Types.TStorageMedium storage_medium
    5: optional Types.TVersion committed_version
    6: optional Types.TVersionHash committed_version_hash
}

struct TStorageMediumMigrateReq {
    1: required Types.TTabletId tablet_id
    2: required Types.TSchemaHash schema_hash
    3: required Types.TStorageMedium storage_medium
}

struct TCancelDeleteDataReq {
    1: required Types.TTabletId tablet_id
    2: required Types.TSchemaHash schema_hash
    3: required Types.TVersion version
    4: required Types.TVersionHash version_hash
}

struct TCheckConsistencyReq {
    1: required Types.TTabletId tablet_id
    2: required Types.TSchemaHash schema_hash
    3: required Types.TVersion version
    4: required Types.TVersionHash version_hash
}

struct TUploadReq {
    1: required i64 job_id;
    2: required map<string, string> src_dest_map
    3: required Types.TNetworkAddress broker_addr
    4: optional map<string, string> broker_prop
}

struct TDownloadReq {
    1: required i64 job_id
    2: required map<string, string> src_dest_map
    3: required Types.TNetworkAddress broker_addr
    4: optional map<string, string> broker_prop
}

struct TSnapshotRequest {
    1: required Types.TTabletId tablet_id
    2: required Types.TSchemaHash schema_hash
    3: optional Types.TVersion version
    4: optional Types.TVersionHash version_hash
    5: optional i64 timeout
    6: optional bool list_files
}

struct TReleaseSnapshotRequest {
    1: required string snapshot_path
}

struct TClearRemoteFileReq {
    1: required string remote_file_path
    2: required map<string, string> remote_source_properties
}

struct TMoveDirReq {
    1: required Types.TTabletId tablet_id
    2: required Types.TSchemaHash schema_hash
    3: required string src
    4: required i64 job_id
    5: required bool overwrite
}

enum TAgentServiceVersion {
    V1
}

struct TAgentTaskRequest {
    1: required TAgentServiceVersion protocol_version
    2: required Types.TTaskType task_type
    3: required i64 signature // every request has unique signature
    4: optional Types.TPriority priority
    5: optional TCreateTabletReq create_tablet_req
    6: optional TDropTabletReq drop_tablet_req
    7: optional TAlterTabletReq alter_tablet_req
    8: optional TCloneReq clone_req
    9: optional TPushReq push_req
    10: optional TCancelDeleteDataReq cancel_delete_data_req
    11: optional Types.TResourceInfo resource_info
    12: optional TStorageMediumMigrateReq storage_medium_migrate_req
    13: optional TCheckConsistencyReq check_consistency_req
    14: optional TUploadReq upload_req
    15: optional TDownloadReq download_req
    16: optional TSnapshotRequest snapshot_req
    17: optional TReleaseSnapshotRequest release_snapshot_req
    18: optional TClearRemoteFileReq clear_remote_file_req
    19: optional TMoveDirReq move_dir_req
}

struct TAgentResult {
    1: required Status.TStatus status
    2: optional string snapshot_path
}

struct TTopicItem {
    1: required string key
    2: optional i64 int_value
    3: optional double double_value
    4: optional string string_value
}

enum TTopicType {
    RESOURCE
}

struct TTopicUpdate {
    1: required TTopicType type
    2: optional list<TTopicItem> updates
    3: optional list<string> deletes
}

struct TAgentPublishRequest {
    1: required TAgentServiceVersion protocol_version
    2: required list<TTopicUpdate> updates
}

struct TMiniLoadEtlTaskRequest {
    1: required TAgentServiceVersion protocol_version
    2: required PaloInternalService.TExecPlanFragmentParams params
}

struct TMiniLoadEtlStatusRequest {
    1: required TAgentServiceVersion protocol_version
    2: required Types.TUniqueId mini_load_id
}

struct TMiniLoadEtlStatusResult {
    1: required Status.TStatus status
    2: required Types.TEtlState etl_state
    3: optional map<string, i64> file_map
    4: optional map<string, string> counters
    5: optional string tracking_url
    // progress
}

struct TDeleteEtlFilesRequest {
    1: required TAgentServiceVersion protocol_version
    2: required Types.TUniqueId mini_load_id
    3: required string db_name
    4: required string label
}

