function [ A ] = readFIJI_csv( filename )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% INPUTS:
%   filename - name of .csv file

% OUTPUTS: 
%   A - m x 2 matrix of (x,y) pairs

% can update later to find the X,Y columns
% for now, just know that the files are read beginning at the second row
% (first row is column headers)
% (X,Y) pairs are in columns 

A = csvread(filename,1,5);

end

