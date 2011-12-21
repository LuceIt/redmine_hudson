/* $Id: revision_build_results.js 316 2009-09-26 15:17:42Z toshiyuki.ando1971 $ */

RevisionBuildResults = Class.create();
RevisionBuildResults.prototype = {
  initialize: function (revision) {
     this.revision = revision;
     this.results = $H();
  },
  add: function( result ) {
     this.results.set(result.job_name + result.number, result);
  }
}


