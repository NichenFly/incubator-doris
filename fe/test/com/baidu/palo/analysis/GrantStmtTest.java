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

package com.baidu.palo.analysis;

import com.baidu.palo.catalog.AccessPrivilege;
import com.baidu.palo.catalog.Catalog;
import com.baidu.palo.common.AnalysisException;
import com.baidu.palo.common.InternalException;
import com.baidu.palo.mysql.privilege.PaloAuth;
import com.baidu.palo.qe.ConnectContext;

import com.google.common.collect.Lists;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import java.util.List;

import mockit.Mocked;
import mockit.NonStrictExpectations;
import mockit.internal.startup.Startup;

public class GrantStmtTest {
    private Analyzer analyzer;

    private PaloAuth auth;
    @Mocked
    private ConnectContext ctx;

    @Mocked
    private Catalog catalog;

    static {
        Startup.initializeIfPossible();
    }

    @Before
    public void setUp() {
        analyzer = AccessTestUtil.fetchAdminAnalyzer(true);
        auth = new PaloAuth();

        new NonStrictExpectations() {
            {
                ConnectContext.get();
                result = ctx;

                ctx.getQualifiedUser();
                result = "root";

                ctx.getRemoteIP();
                result = "192.168.0.1";

                Catalog.getCurrentCatalog();
                result = catalog;

                catalog.getAuth();
                result = auth;
            }
        };
    }

    @Test
    public void testNormal() throws AnalysisException, InternalException {
        GrantStmt stmt;

        List<AccessPrivilege> privileges = Lists.newArrayList(AccessPrivilege.ALL);
        stmt = new GrantStmt(new UserIdentity("testUser", "%"), null, new TablePattern("testDb", "*"), privileges);
        stmt.analyze(analyzer);
        Assert.assertEquals("testCluster:testUser", stmt.getUserIdent().getQualifiedUser());
        Assert.assertEquals("testCluster:testDb", stmt.getTblPattern().getQuolifiedDb());

        privileges = Lists.newArrayList(AccessPrivilege.READ_ONLY, AccessPrivilege.ALL);
        stmt = new GrantStmt(new UserIdentity("testUser", "%"), null, new TablePattern("testDb", "*"), privileges);
        stmt.analyze(analyzer);
    }

    @Test(expected = AnalysisException.class)
    public void testUserFail() throws AnalysisException, InternalException {
        GrantStmt stmt;

        List<AccessPrivilege> privileges = Lists.newArrayList(AccessPrivilege.ALL);
        stmt = new GrantStmt(new UserIdentity("", "%"), null, new TablePattern("testDb", "*"), privileges);
        stmt.analyze(analyzer);
        Assert.fail("No exeception throws.");
    }
}