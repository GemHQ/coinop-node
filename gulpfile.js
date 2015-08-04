
var gulp = require('gulp'),
    browserify = require('browserify'),
    watchify = require('watchify'),
    source = require('vinyl-source-stream'),
    open = require('gulp-open'),
    exit = require('gulp-exit');


// JS
var bundler = watchify(browserify({
  entries: './test/unit/browser_bundle.coffee',
  extensions: ['.coffee']
}));
bundler.transform('coffeeify')

gulp.task('browserify', bundle);

bundler.on('update', bundle);

function bundle() {
  return bundler.bundle()
    .on('error', function(error) {
      console.log(error);
      exit();
    })
    .pipe(source('browser_bundle.js'))
    .pipe(gulp.dest('./lib/test/unit'))
}


// Open Test HTML File
// Will open the test.html file, which will run the
// browser tests
gulp.task('open-test-html', function(){
  gulp.src('./lib/test/unit/test.html')
  .pipe(open());
});



gulp.task('default', ['browserify', 'open-test-html'])
