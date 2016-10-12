var gulp = require('gulp'),
    concat = require('gulp-concat'),
    uglify = require('gulp-uglify'),
    gulp_if = require('gulp-if'),
    less = require('gulp-less'),
    htmlmin = require('gulp-htmlmin'),
    minify = require('gulp-minify-css'),
    nodemon = require('gulp-nodemon'),
    sourcemaps = require('gulp-sourcemaps');

var config = {
    basedir: "htdocs/",
    develop: true
};

// Build client/angular
gulp.task('build-client-angular', function () {
    gulp.src('client/angular/**/*.js')
        .pipe(gulp_if(config.develop, sourcemaps.init()))
        .pipe(concat('app.min.js'))
        .pipe(gulp_if(!config.develop, uglify()))
        .pipe(gulp_if(config.develop, sourcemaps.write()))
        .pipe(gulp.dest(config.basedir));
});

// Build client/scripts
gulp.task('build-client-scripts', function () {
    gulp.src('client/scripts/**/*.js')
        .pipe(gulp_if(config.develop, sourcemaps.init()))
        .pipe(concat('common.min.js'))
        .pipe(gulp_if(!config.develop, uglify()))
        .pipe(gulp_if(config.develop, sourcemaps.write()))
        .pipe(gulp.dest(config.basedir));
});

// Build client/views
gulp.task('build-client-views', function () {
    return gulp.src('client/views/**/*.html')
        .pipe(gulp_if(!config.develop, htmlmin({
            collapseWhitespace: true
        })))
        .pipe(gulp.dest(config.basedir));
});

// Build client/styles
gulp.task('build-client-styles', function () {
    return gulp.src('client/styles/main.less')
        .pipe(less())
        .pipe(concat('common.min.css'))
        .pipe(gulp_if(!config.develop, minify({ keepBreaks: true })))
        .pipe(gulp.dest(config.basedir));
});

// Build server/run
gulp.task('build-server-run', function () {
    return nodemon({
        script: 'server/index.js',
        ext: 'js json html',
        env: { 'NODE_ENV': 'development' },
        watch: ["server"]
    });
});

// File watch
gulp.watch('client/angular/**/*.js', ['build-client-angular']);
gulp.watch('client/scripts/**/*.js', ['build-client-scripts']);
gulp.watch('client/views/**/*.html', ['build-client-views']);
gulp.watch('client/styles/**/*.less', ['build-client-styles']);

// Tasks
gulp.task('build-client', [
    'build-client-angular',
    'build-client-scripts',
    'build-client-styles',
    'build-client-views'
]);

gulp.task('build-server', [
    'build-server-run'
]);

gulp.task('build', ['build-client', 'build-server']);

gulp.task('default', []);
